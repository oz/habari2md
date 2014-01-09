#!/usr/bin/env ruby
require 'fileutils'
require 'pathname'

require 'celluloid'
require 'sequel'

module Habari2md
  # @class Habari2md::Text Text helpers
  class Text
    # Shameless snatch from Rails.
    # @param [String] text
    # @return [String]
    def self.simple_format(text)
      text = '' if text.nil?
      text = text.dup
      start_tag = '<p>'
      text = text.to_str
      text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
      text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
      text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
      text.insert(0, start_tag)
      text << '</p>'
      return text
    end

    # Fork (!) html2text.py to convert form HTML to Markdown.
    #
    # @param [String] content
    # @reutnr [String] Markdown content
    def self.html2text(content)
      IO.popen(html2text_script, "r+") do |io|
        io.write content
        io.close_write
        content = io.read
        io.close_read
      end
      content
    end

    protected

    def self.html2text_script
      @html2text ||= Pathname.new(File.dirname(__FILE__))
                             .join('vendor', 'html2text.py').to_s
    end
  end

  # @class Habari2md::Exporter
  # @example Export stuff
  #   worker = Habari2md::Exporter.new(db: 'foo', user: 'root')
  #   worker.export_posts("./out")
  class Exporter
    attr_reader :db
    include Celluloid
    include Celluloid::Logger

    def initialize(opts = {})
      @db = Sequel.connect(db_uri opts)
      @counter = 0
      @halfway = 0

      # Cache users
      @users = @db[:users].all.inject({}) do |cache, user|
        cache.merge!([user[:id]] => user)
      end
    end

    def posts
      db[:posts].order(:modified)
    end

    # @return [Hash]
    def user(id)
      @users.fetch(id, {})
    end

    def export_posts(directory)
      FileUtils.mkdir_p(directory) unless File.directory?(directory)

      @counter = posts.count
      @halfway = @counter / 2

      info "Exporting #{@counter} posts..."

      pool = Habari2md::PostExporter.pool(args: [directory, current_actor])
      posts.each { |post| pool.async.export(post) }

      wait(:done)
      info "We're done."
    end

    # Called by PostExport when an export operation has finished.
    def post_exported(post_id)
      @counter -= 1
      info "50% to go" if @counter == @halfway
      signal(:done) if @counter == 0
    end

    protected

    def db_uri(opts)
      "mysql://#{opts[:user]}:#{opts[:password]}@#{opts[:host]}/#{opts[:db]}"
    end
  end

  # @class Habari2md::PostExporter Export one post
  class PostExporter
    include Celluloid

    # Output directory
    attr_reader :dir

    # Manager actor
    attr_reader :manager

    def initialize(dest_dir, manager_actor)
      @dir = Pathname.new(dest_dir)
      @manager = manager_actor
    end

    # Placeholder title for untitled posts
    def untitled
      "Untitled"
    end

    # Signal the managing actor when a post has been exported
    def done(post = {})
      manager.post_exported(post[:id])
    end

    # Export one post to disk
    # @param [Hash] post
    def export(post)
      # Ignore deleted posts and drafts.
      return done(post) unless published?(post)

      author = manager.user(post[:user_id])[:username]
      title = post[:title].gsub(/[\r\n]/, '')
      title = untitled if title == ""
      date = Time.strptime(post[:pubdate].to_s, "%s").strftime("%Y-%m-%d")
      filename = dir.join("#{date}-#{post[:slug]}.md")
      return done(post) if File.exists?(filename) && ENV['FORCE'] == nil

      # Make sure content is at least formatted with <p> tags before
      # conversion.
      content = Habari2md::Text.simple_format(post[:content])
      File.open(filename, 'w+') do |fh|
        fh << "---\n"
        fh << "title: #{title}\n"
        fh << "author: #{author}\n" unless author == nil
        fh << "---\n\n"
        fh << Habari2md::Text.html2text(content)
      end

      done(post)
    end

    # This actually depends on the values in the poststatus table.
    def published?(post)
      post[:status] == 2
    end
  end
end

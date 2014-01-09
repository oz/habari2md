# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'habari2md/version'

Gem::Specification.new do |spec|
  spec.name          = "habari2md"
  spec.version       = Habari2md::VERSION
  spec.authors       = ["Arnaud Berthomier"]
  spec.email         = ["oz@cyprio.net"]
  spec.summary       = %q{Habari to markdown}
  spec.description   = %q{Dump a Habari blog posts to Markdown format}
  spec.homepage      = "https://github.com/oz/habari2md"
  spec.license       = "GPL v3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency "celluloid", "~> 0.15"
  spec.add_dependency "sequel",    "~> 4.5"
  spec.add_dependency "mysql",     "~> 2.9"
end

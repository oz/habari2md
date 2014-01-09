# Habari2md

This is a dirty little Ruby program to export a [Habari][habari] blog to
markdown format.  I used it to avoid installing PHP on a small VPS in order to
run a tiny blog of ~2000 posts.

The program makes a few assumptions about your setup, and this conditions what
you should expect to get from it.

  * It will connect to a MariaDB/MySQL database,
  * fetch all of its posts and:
    * dump one file per published post in the `out` directory ;
    * use a filename like `YYYY-MM-DD-post-slug.md` where `YYYY-MM-DD` are the
      year, month, and month day when a particular post was published ;
    * and format a post header with:
        
        ```
        title: The original post title
        author: The author's username
        ```

This process can be pretty specific, and if it does not fit your setup, feel
free to file an issue or, better, send a pull-request. ;)

# Dependencies

 * Ruby >= 1.9
 * Python >= 2.x

# Installation

`gem install habari2md`

# Usage

```
$ habari2md -h
Usage: habari2md [options]
    -o, --output [DIR]               Output directory
    -s, --host [HOST]                Database host
    -d, --db [DB]                    Database name
    -u, --user [USER]                Database user
    -p, --password [PASS]            Database password
    -h, --help                       Show this message
$ habari2md -o foobar -d my_blog_database -h localhost -u sql_user -p sql_password
I, [2014-01-08T23:31:20.771303 #74090]  INFO -- : Exporting 12345 posts...
I, [2014-01-08T23:31:50.618731 #74090]  INFO -- : 50% to go
I, [2014-01-08T23:32:20.081583 #74090]  INFO -- : We're done.
D, [2014-01-08T23:32:20.083582 #74090] DEBUG -- : Terminating 6 actors...
W, [2014-01-08T23:32:20.084398 #74090]  WARN -- : Terminating task: type=:finalizer, meta={:method_name=>:__shutdown__}, status=:callwait
➜
```

# License

GPL 3.0

Note: this distribution contains Aaron Swartz [html2text][html2text] GPL
licensed program. As a matter of fact, we fork one process to convert each post
from HTML to [Markdown][markdown], yay!

[habari]: http://habariproject.org/
[html2text]: http://www.aaronsw.com/2002/html2text/
[markdown]: http://daringfireball.net/projects/markdown/

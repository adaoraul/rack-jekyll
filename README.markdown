Rack-Jekyll
===========

Transform your [Jekyll](http://github.com/mojombo/jekyll) app
into a [Rack](http://github.com/rack/rack) application.

- You can run it with rackup, [shotgun](http://github.com/rtomakyo/shotgun),
  [unicorn](http://github.com/defunkt/unicorn), and more.
- You can run Rack-Jekyll with any modified Jekyll.
- You can deploy Rack-Jekyll on Heroku, EC2, Slicehost, Rackspace Cloud,
  dedicated server, VPS, etc.


### How to use it?

A `config.ru` file is required in order to run with shotgun and rackup.
You can even deploy your Jekyll app to [Heroku](http://www.heroku.com/)!

Copy this into `config.ru` in your Jekyll site's root directory:

``` ruby
require "rack/jekyll"

run Rack::Jekyll.new
```

That's it.

Heroku is a [read-only filesystem](http://docs.heroku.com/constraints#read-only-filesystem):

You need to generate pages and git-add pages and git-commit
before you deploy your Jekyll to Heroku.

 1. `cd` to your Jekyll directory
 2. add `config.ru` file (see example above)
 3. build pages, type: `jekyll`
 4. `echo "rack-jekyll" > .gems`
 5. `git init && git add .`
 6. `git commit -m "first heroku app"`
 7. `heroku create`
 8. `git push heroku master`


## Initialization Options

    :config        - use given config file (default: "_config.yml")
    :destination   - use given destination path (default: "_site")
    :force_build   - whether to always generate the site at startup, even
                     when the destination path is not empty (default: false)

Example:

``` ruby
run Rack::Jekyll.new(:destination => "mysite")
```

Note that on read-only filesystems (like e.g. Heroku) a site build will fail,
so do not set `:force_build => true` in these cases.


## YAML Config

Rack-Jekyll now can read the destination path from the `_config.yml` file.
Read [Jekyll Configuration](http://jekyllrb.com/docs/configuration/).


## 404 page

You can create a new file: `404.html` with YAML front matter.
See my [Heroku Demo 404](http://bry4n.heroku.com/show/me/404/).



## Contributors

* adaoraul (Adão Raul)
* Nerian (Gonzalo Rodríguez-Baltanás Díaz)
* scottwater (Scott Watermasysk)
* thedjinn (Emil Loer)
* bry4n (Bryan Goines)
* thibaudgg (Thibaud Guillaume-Gentil)
* bemurphy (Brendon Murphy)
* imajes (James Cox)
* mattr- (Matt Rogers)


## Contribution

Contributions are more than just welcome.
Fork this and create a new branch then open a pull request.

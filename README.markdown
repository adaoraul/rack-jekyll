Rack-Jekyll
===========

Transform your [Jekyll](https://jekyllrb.com/) app
into a [Rack](https://github.com/rack/rack) application.

- You can run it with rackup, [shotgun](https://github.com/rtomayko/shotgun),
  [unicorn](http://unicorn.bogomips.org/), and more.
- You can run Rack-Jekyll with any modified Jekyll.
- You can deploy Rack-Jekyll to Heroku, EC2, Rackspace,
  dedicated servers, VPS, etc.


## How to use it

A `config.ru` file is required in order to run with shotgun and rackup.
You can even deploy your Jekyll app to [Heroku](https://www.heroku.com/)!

Copy this into `config.ru` in your Jekyll site's root directory:

``` ruby
require "rack/jekyll"

run Rack::Jekyll.new
```

That's it.

Heroku provides a read-only filesystem, so you need to generate pages
and git-commit them *before* you deploy your Jekyll site to Heroku.

 1. `cd` to your Jekyll directory
 2. add a `config.ru` file (see example above)
 3. build pages with `jekyll build`
 4. add `gem "rack-jekyll"` to your `Gemfile`
 5. `git init && git add .`
 6. `git commit -m "Initial commit"`
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

Note that on read-only filesystems a site build will fail,
so do not set `:force_build => true` in these cases.


## YAML Config

Rack-Jekyll now can read the destination path from the `_config.yml` file.
Read [Jekyll Configuration](http://jekyllrb.com/docs/configuration/).


## 404 page

In your site's root directory you can provide a custom `404.html` file
with YAML front matter.


## Contributing

Contributions are more than just welcome.
Fork this repo and create a new branch, then submit a pull request.


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

Rack-Jekyll
===========

Transform your [Jekyll](http://github.com/mojombo/jekyll) app into a [Rack](http://github.com/rack/rack) application.

- Can run it with rackup and [shotgun](http://github.com/rtomakyo/shotgun), [unicorn](http://github.com/defunkt/unicorn), and more.

- Can run rack-jekyll with any modified Jekyll.

- Can deploy rack-jekyll on Heroku, EC2, Slicehost, Rackspace Cloud, Dedicated server, VPS, etc.


### How to use it?

*config.ru* is required in order to run with shotgun and rackup. You can even deploy your Jekyll app to [Heroku](http://www.heroku.com/)!

Copy this into config.ru in your Jekyll's root directory.


config.ru:

    require "rack/jekyll"

    run Rack::Jekyll.new


That's it.


Heroku is a [read-only filesystem](http://docs.heroku.com/constraints#read-only-filesystem):

You need to generate pages and git-add pages and git-commit before you deploy your Jekyll to Heroku.

    1) cd to your Jekyll directory

    2) add config.ru (see example above)

    3) build pages, type: jekyll

    4) echo "rack-jekyll" > .gems

    5) git init && git add .

    6) git commit -m "first heroku app"

    7) heroku create

    8) git push heroku master


## Initialization Options

    :config               - use custom config file (default: "_config.yml")
    :destination          - use custom destination path (default: "_site")


*Example:*

    run Rack::Jekyll.new(:destination => "mysite")


## YAML Config

rack-jekyll now can read the destination path from the `_config.yml` file. Read [Jekyll Configuration](http://jekyllrb.com/docs/configuration/).


## 404 page

You can create a new file: `404.html` with YAML Front Matter. See my [Heroku Demo 404](http://bry4n.heroku.com/show/me/404/).

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

Contributions are more than just welcome. Fork this and create a new branch then open a pull request.

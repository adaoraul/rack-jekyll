Rack-Jekyll
===========

Transform your [Jekyll](http://github.com/mojombo/jekyll) app into [Rack](http://github.com/rack/rack) application

- Can run it with rackup and [shotgun](http://github.com/rtomakyo/shotgun), [unicorn](http://github.com/defunkt/unicorn), and more.

- Can run rack-jekyll with any modified jekyll

- Can deploy rack-jekyll on Heroku, EC2, Slicehost, Rackspace Cloud, Dedicated server, VPS, etc..


Heroku Demo: [http://bry4n.heroku.com/](http://bry4n.heroku.com/)

### How to use it?

*config.ru* is required in order to run with shotgun and rackup. Even you can deploy your jekyll app to [Heroku!](http://www.heroku.com/)

Copy this and put in config.ru in your jekyll's root directory.


config.ru:

    require "rack/jekyll"

    run Rack::Jekyll.new


That's it.


Heroku is a [read-only filesystem](http://docs.heroku.com/constraints#read-only-filesystem):

You need to generate pages and git-add pages and git-commit before you deploy your jekyll to Heroku

    1) cd to your jekyll directory

    2) add config.ru (see example above)
    
    3) build pages, type: jekyll
    
    4) echo "rack-jekyll" > .gems
    
    5) git init && git add .
    
    6) git commit -m "first heroku app"
    
    7) heroku create
    
    8) git push heroku master


## Initialization Options

    :destination          - use the desintation path (default: _site)
    :wait_page            - a page to display while pages are rendering


*Example:*

    run Rack::Jekyll.new(:destination => "mysite")


## YAML Config

It now can read the `_config.yml` file for destination path. Read [Jekyll Configuration](http://jekyllrb.com/docs/configuration/)


## 404 page

You can create a new file: `404.html` with YAML Front Matter. See my [Heroku Demo 404](http://bry4n.heroku.com/show/me/404/)

## Wait page

You can create a custom HTML page to display while Jekyll is rendering the
site.  Set the `:wait_page` initialization option to point to a file relative
to the root of your Jekyll project.

*Example:*

    run Rack::Jekyll.new(:wait_page => "hold_on.html")

Note that this page should be self-contained (no links to external CSS
or JS).  It is also not a bad idea to add a `<meta http-equiv="refresh"
content="60"/>` to the `head` section so that the page will periodically
refresh itself and display the site once Jekyll has finished rendering.

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

Contributing this is more than just welcome. Fork this and create a new branch then pull request.

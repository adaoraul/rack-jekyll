Rack-Jekyll
===========

Transform your [Jekyll](http://github.com/mojombo/jekyll) app into [Rack](http://github.com/rack/rack) application

You can run it with rackup and [shotgun](http://github.com/rtomakyo/shotgun).

Heroku Demo: [http://bry4n.heroku.com/](http://bry4n.heroku.com/)

### How to use it?

*config.ru* is required in order to run with shotgun and rackup. Even you can deploy your jekyll app to [Heroku!](http://www.heroku.com/)

Copy this and put in config.ru in your jekyll's root directory.


config.ru:

    require "rack/jekyll"

    run Rack::Jekyll.new


That's it.


Heroku's dyno is a [read-only filesystem](http://docs.heroku.com/constraints#read-only-filesystem):

You need to generate pages and git-add pages and git-commit before you deploy your jekyll to Heroku

    1) cd to your jekyll directory

    2) add config.ru (see example above)
    
    3) build pages, type: jekyll
    
    4) git init && git add _site/*
    
    5) git commit -m "first heroku app"
    
    6) heroku create
    
    7) git push heroku master

## 404 page

You can create a new file: `404.html` with YAML Front Matter. See my [Heroku Demo 404](http://bry4n.heroku.com/show/me/404/)

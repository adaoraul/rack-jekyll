Rack-Jekyll
===========

Transform your Jekyll app into Rack application

You can run it with rackup and shotgun.

Demo: [http://bry4n.heroku.com/](http://bry4n.heroku.com/)

### How to use it?

*config.ru* is required in order to run with shotgun and rackup. Even you can deploy your jekyll app to Heroku!

Copy this and put in config.ru in your jekyll's root directory.


config.ru:

    require "rack/jekyll"

    run Rack::Jekyll.new


That's it.


Heroku:

You need to generate pages and git-add pages and git-commit before you deploy your jekyll to Heroku

    1) cd to your jekyll directory

    2) add config.ru (see example above)
    
    3) build pages, type: jekyll
    
    4) git init && git add .
    
    5) git commit -m "first heroku app"
    
    6) heroku create
    
    7) git push heroku master

## TODO

Rails 

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


## TODO

Rails 

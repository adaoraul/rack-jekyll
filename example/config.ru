require File.join(File.dirname(__FILE__), '../lib/rack', 'jekyll')

# The jekyll root directory
root = ::File.dirname(__FILE__)

# Middleware
use Rack::ShowStatus      # Nice looking 404s and other messages
use Rack::ShowExceptions  # Nice looking errors

run Rack::URLMap.new( {
  "/" => Rack::Directory.new( "public" ), # Serve our static content
  "/" => Rack::Jekyll.new                 # Jekyll app
} )

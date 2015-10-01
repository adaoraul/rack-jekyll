require File.expand_path("../../lib/rack/jekyll", __FILE__)

# Middleware
use Rack::ShowStatus      # Nice looking 404s and other messages
use Rack::ShowExceptions  # Nice looking errors

run Rack::Jekyll.new

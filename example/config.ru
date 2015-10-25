require File.expand_path("../../lib/rack/jekyll", __FILE__)

# Middleware
use Rack::ShowExceptions  # Nice looking errors

run Rack::Jekyll.new

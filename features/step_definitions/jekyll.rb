require "lib/rack/jekyll/test"
require "rack/mock"

Given /^I haven entered the path (.*)$/ do |p|
  @config = File.dirname(__FILE__) + "/config.ru"
  @jekyll = Rack::Jekyll::Test.new(@config)
  @path = p
end

When /^I request a page$/ do
  @request = get(@path)
end

Then /^the http status should be (.*)$/ do |code|
  true if @request.status == code
end

Then /^the content\-type should be (.*)$/ do |type|
  true if @request.headers["Content-Type"] == type
end

def get(path)
  req = Rack::MockRequest.new(@jekyll)
  req.get(path)
end

require_relative "../../lib/rack/jekyll/test"
require "rack/mock"

Given /^I have entered the path (.*)$/ do |path|
  @jekyll = Rack::Jekyll::Test.new
  @path = path
end

When /^I request a page$/ do
  @request = get(@path)
end

When /^I request a page with a date of '(.*)'$/ do |date|
  @request = get(@path, {'HTTP_IF_MODIFIED_SINCE' => date})
end


Then /^the http status should be (.*)$/ do |code|
  true if @request.status == code
end

Then /^the content\-type should be (.*)$/ do |type|
  true if @request.headers["Content-Type"] == type
end

Then /^the content\-length should be (.*)$/ do |length|
  true if @request.headers["Content-Length"] == length
end

Then /^the data should show (.*)$/ do |body|
  true if @request.body == body
end

def get(path, headers={})
  req = Rack::MockRequest.new(@jekyll)
  req.get(path,headers)
end

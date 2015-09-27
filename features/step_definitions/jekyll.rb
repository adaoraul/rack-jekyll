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
  assert_equal(code, @request.status.to_s)
end

Then /^the content\-type should be (.*)$/ do |type|
  assert_equal(type, @request.headers["Content-Type"])
end

Then /^the content\-length should be (.*)$/ do |length|
  assert_equal(length, @request.headers["Content-Length"])
end

Then /^the data should show (.*)$/ do |body|
  assert_equal(body, @request.body)
end

Then /^there should be no '(.*)' header$/ do |header|
  assert_false @request.headers.has_key?(header)
end

def get(path, headers={})
  req = Rack::MockRequest.new(@jekyll)
  req.get(path,headers)
end

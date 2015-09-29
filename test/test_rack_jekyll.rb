require "minitest/autorun"
require "rack/mock"
require_relative "../lib/rack/jekyll/test"

describe Rack::Jekyll do

  before do
    @jekyll = Rack::Jekyll::Test.new
    @request = Rack::MockRequest.new(@jekyll)
  end

  it "can be created" do
    refute_nil @jekyll
    refute_nil @request
  end

  it "should return correct http status code" do
    assert_equal(@request.get("/").status,200)
    assert_equal(@request.get("/show/me/404").status,404)
    assert_equal(@request.get("/", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 15:27:52 GMT'}).status,304)
    assert_equal(@request.get("/", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 13:27:52 GMT'}).status,200)
    assert_equal(@request.get("/show/me/404", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 13:27:52 GMT'}).status,404)
  end

  it "should return correct Content-Type header" do
    assert_equal(@request.get("/").headers["Content-Type"],"text/html")
    assert_equal(@request.get("/css/test.css").headers["Content-Type"],"text/css")
    assert_equal(@request.get("/js/test.js").headers["Content-Type"],"application/javascript")
    assert_equal(@request.get("/js/test.min.js").headers["Content-Type"],"application/javascript")
    assert_equal(@request.get("/show/me/404").headers["Content-Type"],"text/html")
  end

  it "should return correct Content-Length header" do
    assert_equal(@request.get("/").headers["Content-Length"].to_i, 11)
    assert_equal(@request.get("/show/me/404").headers["Content-Length"].to_i,9)
    assert_nil(@request.get("/", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 15:27:52 GMT'}).headers["Content-Length"])
  end

  it "should return correct body" do
    assert_equal(@request.get("/").body,"Jekyll/Rack")
    assert_equal(@request.get("/show/me/404").body,"Not found")
  end
end

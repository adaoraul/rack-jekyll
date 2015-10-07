require_relative "helper"

require_relative "../lib/rack/jekyll/test"

describe Rack::Jekyll do

  before do
    @jekyll = Rack::Jekyll::Test.new
    @request = Rack::MockRequest.new(@jekyll)
  end

  it "can be created" do
    @jekyll.wont_be_nil
    @request.wont_be_nil
  end

  it "should return correct http status code" do
    @request.get("/").status.must_equal 200
    @request.get("/show/me/404").status.must_equal 404
    @request.get("/", {"HTTP_IF_MODIFIED_SINCE" => "Thu, 01 Apr 2010 15:27:52 GMT"}).status.must_equal 304
    @request.get("/", {"HTTP_IF_MODIFIED_SINCE" => "Thu, 01 Apr 2010 13:27:52 GMT"}).status.must_equal 200
    @request.get("/show/me/404", {"HTTP_IF_MODIFIED_SINCE" => "Thu, 01 Apr 2010 13:27:52 GMT"}).status.must_equal 404
  end

  it "should return correct Content-Type header" do
    @request.get("/").headers["Content-Type"].must_equal "text/html"
    @request.get("/css/test.css").headers["Content-Type"].must_equal "text/css"
    @request.get("/js/test.js").headers["Content-Type"].must_equal "application/javascript"
    @request.get("/js/test.min.js").headers["Content-Type"].must_equal "application/javascript"
    @request.get("/show/me/404").headers["Content-Type"].must_equal "text/html"
  end

  it "should return correct Content-Length header" do
    @request.get("/").headers["Content-Length"].to_i.must_equal 11
    @request.get("/show/me/404").headers["Content-Length"].to_i.must_equal 9
    @request.get("/", {"HTTP_IF_MODIFIED_SINCE" => "Thu, 01 Apr 2010 15:27:52 GMT"}).headers["Content-Length"].must_be_nil
  end

  it "should return correct body" do
    @request.get("/").body.must_equal "Jekyll/Rack"
    @request.get("/show/me/404").body.must_equal "Not found"
  end
end

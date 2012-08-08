require "test/unit"
require "rack/mock"
require_relative "../lib/rack/jekyll/test"
class RackJekyllTest < Test::Unit::TestCase
  def setup
    @jekyll = Rack::Jekyll::Test.new    
    @request = Rack::MockRequest.new(@jekyll)
  end
  
  def test_setup
    assert_not_nil @jekyll
    assert_not_nil @request
  end

  def test_http_status_codes
    assert_equal(@request.get("/").status, 200)
    assert_not_equal(@request.get("/").status,404)
    assert_equal(@request.get("/show/me/404").status,404)
    assert_not_equal(@request.get("/show/me/404").status,200)
    assert_equal(@request.get("/", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 15:27:52 GMT'}).status,304)
    assert_equal(@request.get("/", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 13:27:52 GMT'}).status,200)
    assert_equal(@request.get("/show/me/404", {'HTTP_IF_MODIFIED_SINCE' => 'Thu, 01 Apr 2010 13:27:52 GMT'}).status,404)
  end

  def test_content_types
    assert_equal(@request.get("/").headers["Content-Type"],"text/html")
    assert_equal(@request.get("/css/test.css").headers["Content-Type"],"text/css")
    assert_equal(@request.get("/js/test.js").headers["Content-Type"],"application/javascript")
    assert_equal(@request.get("/js/test.min.js").headers["Content-Type"],"application/javascript")
  end

  def test_content_length
    assert_equal(@request.get("/").headers["Content-Length"].to_i, 11)
    assert_not_equal(@request.get("/").headers["Content-Length"].to_i, 12)
  end
  
  def test_contents 
    assert_equal(@request.get("/").body,"Jekyll/Rack")
    assert_equal(@request.get("/show/me/404").body,"Not found")
  end
end


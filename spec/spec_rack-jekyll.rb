require 'bacon'
require 'rack/mock'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/rack/jekyll/test'))

def get(klass, path)
  request = Rack::MockRequest.new(klass)
  request.get(path)
end

describe "Jekyll to Rack" do
  
  jekyll = Rack::Jekyll::Test.new
  
  
  it "should be 200 and not 404" do
    res = get(jekyll,"/")
    res.status.should.equal 200
    res.status.should.not.equal 404
  end

  it "should be 11" do
    res = get(jekyll,"/")
    res.headers["Content-Length"].to_i.should.equal 11
  end

  it "should be text/html" do
    res = get(jekyll,"/")
    res.headers["Content-Type"].should.equal "text/html"
  end
  
  it "should show Jekyll/Rack" do
    res = get(jekyll,"/")
    res.body.should.equal "Jekyll/Rack"
  end

  it "should be 404 and not 200" do
    res = get(jekyll,"/show/me/404")
    res.status.should.not.equal 200
    res.status.should.equal 404
  end
  
  it "should be text/css" do
    res = get(jekyll,"/css/test.css")
    res.headers["Content-Type"].should.equal "text/css"
  end
  
  it "should be application/javascript" do
    res = get(jekyll,"/js/test.js")
    res.headers["Content-Type"].should.equal "application/javascript"
  end
  
  it "should be application/javascript even when minified" do
    res = get(jekyll,"/js/test.min.js")
    res.headers["Content-Type"].should.equal "application/javascript"
  end

  
end

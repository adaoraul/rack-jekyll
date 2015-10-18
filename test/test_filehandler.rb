require_relative "helper"


describe "when mapping paths to files" do

  before do
    files = [
      "/site/index.html",
      "/site/page.html",
      "/site/README",
      "/site/dir-with-index/index.html",
      "/site/dir-without-index/page.html",
      "/site/dir1/dir2/dir3/index.html"
    ]
    @filehandler = Rack::Jekyll::FileHandler.new("/site", files)
  end

  describe "when asked for filenames with #get_filename" do

    it "should return path for '/'" do
      @filehandler.get_filename("/").must_equal "/site/index.html"
    end

    it "should return existing path" do
      @filehandler.get_filename("/page.html").must_equal "/site/page.html"
    end

    it "should return nil for non-existent path" do
      @filehandler.get_filename("/not-a-page.html").must_be_nil
    end

    it "should return existing path for resource without extension" do
      @filehandler.get_filename("/README").must_equal "/site/README"
    end

    it "should return nil for partially matching paths" do
      @filehandler.get_filename("/dir1/dir2/").must_be_nil
      @filehandler.get_filename("/dir2/dir3").must_be_nil
      @filehandler.get_filename("ir1/di").must_be_nil
    end

    it "should return path for directory/ with index" do
      @filehandler.get_filename("/dir-with-index/").must_equal "/site/dir-with-index/index.html"
    end

    it "should return path for directory with index" do
      @filehandler.get_filename("/dir-with-index").must_equal "/site/dir-with-index/index.html"
    end

    it "should return nil for directory/ without index" do
      @filehandler.get_filename("/dir-without-index/").must_be_nil
    end

    it "should return nil for directory without index" do
      @filehandler.get_filename("/dir-without-index").must_be_nil
    end
  end
end

require "minitest/autorun"
require "stringio"
require "jekyll"
require_relative "../lib/rack/jekyll"

module Jekyll
  class Site
    def process; end  # prevent build
  end
end

TEST_DIR = File.expand_path("../tmp", __FILE__)


def new_rack_jekyll(options = {})
  original_stderr, original_stdout = $stderr, $stdout
  $stderr, $stdout = StringIO.new, StringIO.new
  rack_jekyll = Rack::Jekyll.new(options)
  $stderr, $stdout = original_stderr, original_stdout

  rack_jekyll
end


describe "when configuring site" do

  before do
    FileUtils.mkdir_p(TEST_DIR) unless File.exist?(TEST_DIR)
    Dir.chdir(TEST_DIR)
  end

  after do
    FileUtils.rmdir(TEST_DIR) if File.exist?(TEST_DIR)
  end

  describe "when no options are given and no config file exists" do

    it "loads the correct default destination" do
      jekyll = new_rack_jekyll
      jekyll.config["destination"].must_equal File.join(Dir.pwd, "_site")
    end
  end

  describe "when _config.yml exists" do

    it "loads the configuration from file" do
      begin
        File.open("_config.yml", "w") do |f|
          f.puts "config_file_opt: ok"
        end

        jekyll = new_rack_jekyll
        jekyll.config.must_include "config_file_opt"
        jekyll.config["config_file_opt"].must_equal "ok"
      ensure
        FileUtils.rm("_config.yml")
      end
    end
  end

  describe "when initialization options are given" do

    it "has the initialization options" do
      jekyll = new_rack_jekyll(:init_opt => "ok")
      jekyll.config.must_include "init_opt"
      jekyll.config["init_opt"].must_equal "ok"
    end
  end

  describe "when initialization options are given and a config file exists" do

    it "has all options and initialization options override file options" do
      begin
        File.open("_config.yml", "w") do |f|
          f.puts "config_file_opt: ok"
          f.puts "common_opt:      from config"
        end

        jekyll = new_rack_jekyll(:init_opt   => "ok",
                                 :common_opt => "from init")
        jekyll.config.must_include "init_opt"
        jekyll.config.must_include "config_file_opt"
        jekyll.config.must_include "common_opt"
        jekyll.config["common_opt"].must_equal "from init"
      ensure
        FileUtils.rm("_config.yml")
      end
    end
  end
end

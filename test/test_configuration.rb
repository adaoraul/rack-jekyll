require "minitest/autorun"
require "stringio"
require_relative "../lib/rack/jekyll"

TEST_DIR = File.expand_path("..", __FILE__)


def silence_warnings
  original_verbose, $VERBOSE = $VERBOSE, nil

  yield
ensure
  $VERBOSE = original_verbose
end

def silence_output
  original_stderr, original_stdout = $stderr, $stdout
  $stderr, $stdout = StringIO.new, StringIO.new

  yield
ensure
  $stderr, $stdout = original_stderr, original_stdout
end

def without_processing
  silence_warnings do
    Jekyll::Site.class_eval do
      alias :original_process :process
      def process; end
    end
  end

  yield
ensure
  silence_warnings do
    Jekyll::Site.class_eval do
      alias :process :original_process
      remove_method :original_process
    end
  end
end

def rack_jekyll(options = {})
  jekyll = nil
  silence_output do
    jekyll = Rack::Jekyll.new(options)
  end

  jekyll
end

def rack_jekyll_without_build(options = {})
  jekyll = nil
  without_processing do
    jekyll = rack_jekyll(options)
  end

  jekyll
end


describe "when configuring site" do

  before do
    @tempdir = File.join(TEST_DIR, "tmp")
    FileUtils.mkdir_p(@tempdir)  unless File.exist?(@tempdir)
    Dir.chdir(@tempdir)
  end

  after do
    FileUtils.rmdir(@tempdir)  if File.exist?(@tempdir)
  end

  describe "when no options are given and no config file exists" do

    it "loads the correct default destination" do
      jekyll = rack_jekyll_without_build
      jekyll.destination.must_equal File.join(Dir.pwd, "_site")
    end
  end

  describe "when using default config file" do

    it "loads the configuration from file" do
      begin
        File.open("_config.yml", "w") do |f|
          f.puts "config_file_opt: ok"
        end

        jekyll = rack_jekyll_without_build
        jekyll.config.must_include "config_file_opt"
        jekyll.config["config_file_opt"].must_equal "ok"
      ensure
        FileUtils.rm("_config.yml")
      end
    end
  end

  describe "when using custom config file" do

    it "loads the configuration from file" do
      begin
        File.open("_my_config.yml", "w") do |f|
          f.puts "config_file_opt: ok"
        end

        jekyll = rack_jekyll_without_build(:config => "_my_config.yml")
        jekyll.config.must_include "config_file_opt"
        jekyll.config["config_file_opt"].must_equal "ok"
      ensure
        FileUtils.rm("_my_config.yml")
      end
    end
  end

  describe "when initialization options are given" do

    it "has the initialization options" do
      jekyll = rack_jekyll_without_build(:init_opt => "ok")
      jekyll.config.must_include "init_opt"
      jekyll.config["init_opt"].must_equal "ok"
    end

    it "has the correct destination" do
      jekyll = rack_jekyll_without_build(:destination => "/project/_site")
      jekyll.destination.must_equal "/project/_site"
    end

    it ":auto is not passed on to Jekyll" do
      jekyll = rack_jekyll_without_build(:auto => "ok")
      jekyll.config.wont_include "auto"
    end

    it ":force_build is not passed on to Jekyll" do
      jekyll = rack_jekyll_without_build(:force_build => "ok")
      jekyll.config.wont_include "force_build"
    end
  end

  describe "when initialization options are given and a config file exists" do

    before do
      File.open("_config.yml", "w") do |f|
        f.puts "config_file_opt: ok"
        f.puts "common_opt:      from config"
        f.puts "destination:     /project/_site_from_config"
      end
    end

    after do
      FileUtils.rm("_config.yml")
    end

    it "has all options and initialization options override file options" do
      jekyll = rack_jekyll_without_build(:init_opt   => "ok",
                                         :common_opt => "from init")
      jekyll.config.must_include "init_opt"
      jekyll.config.must_include "config_file_opt"
      jekyll.config.must_include "common_opt"
      jekyll.config["common_opt"].must_equal "from init"
    end

    it "has the correct destination" do
      jekyll = rack_jekyll_without_build(:destination => "/project/_site_from_init")
      jekyll.destination.must_equal "/project/_site_from_init"
    end
  end
end

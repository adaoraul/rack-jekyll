# coding: utf-8

require File.join(File.dirname(__FILE__), "lib", "rack", "jekyll", "version")

Gem::Specification.new do |s|
 s.required_rubygems_version = ">= 1.3.6"

 s.name        = "rack-jekyll"
 s.version     = Rack::Jekyll.version

 s.summary     = "Transform your Jekyll app into a Rack application."
 s.description = "Rack-Jekyll transforms your Jekyll app into a Rack application."

 s.authors  = ["Bryan Goines", "Adão Raul"]
 s.email    = "adao.raul@gmail.com"
 s.homepage = "https://github.com/adaoraul/rack-jekyll"

 s.files = %w{
             README.markdown
             rack-jekyll.gemspec
             Gemfile
             Rakefile
             LICENSE
           } +
           Dir.glob("lib/**/*")
 s.test_files = Dir.glob("{test,spec,features}/**/*")
 s.require_paths = ["lib"]

 s.extra_rdoc_files = ["README.markdown"]
 s.rdoc_options = ['--charset=UTF-8', '--main=README.markdown']

 s.add_dependency "jekyll", ">= 1.3"
 s.add_dependency "rack", "~> 1.5"

 s.add_development_dependency "rake"
 s.add_development_dependency "minitest"

 s.platform = Gem::Platform::RUBY
 s.rubyforge_project = "rack-jekyll"
end

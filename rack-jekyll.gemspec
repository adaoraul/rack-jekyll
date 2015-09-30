# coding: utf-8

require File.join(File.dirname(__FILE__), "lib", "rack", "jekyll", "version")

Gem::Specification.new do |s|
 s.required_rubygems_version = ">= 1.3.6"
 s.rubygems_version          = "1.3.1"

 s.name        = "rack-jekyll"
 s.version     = Rack::Jekyll.version
 s.summary     = "rack-jekyll"
 s.description = "Transform your jekyll based app into a Rack application"

 s.authors  = ["Bryan Goines", "Adão Raul"]
 s.email    = "adao.raul@gmail.com"
 s.homepage = "http://github.com/adaoraul/rack-jekyll"

 s.files  = ['README.markdown', 'LICENSE', 'lib/rack/jekyll.rb', 'lib/rack/jekyll/test.rb', 'lib/rack/jekyll/helpers.rb', 'lib/rack/jekyll/version.rb', 'lib/rack/jekyll/ext.rb']
 s.require_paths = ["lib"]

 s.extra_rdoc_files = ["README.markdown"]

 s.add_dependency "jekyll", ">= 1.3"
 s.add_dependency "rack", "~> 1.5"
 s.add_development_dependency "bacon"

 s.platform = Gem::Platform::RUBY
 s.rubyforge_project = "rack-jekyll"
end

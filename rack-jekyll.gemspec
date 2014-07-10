# coding: utf-8

require File.join(File.dirname(__FILE__), 'lib', 'rack', 'jekyll', 'version')

Gem::Specification.new do |s|
 s.required_rubygems_version = ">= 1.3.6"

 s.name     = 'rack-jekyll'
 s.version  = Rack::Jekyll.version
 s.description  = "Transform your jekyll based app into a Rack application"
 s.summary  = "rack-jekyll"

 s.authors  = ['Bryan Goines', 'Adão Raul']
 s.email  = 'adao.raul@gmail.com'

 s.files  = ['README.markdown', 'LICENSE', 'lib/rack/jekyll.rb', 'lib/rack/jekyll/test.rb', 'lib/rack/jekyll/helpers.rb', 'lib/rack/jekyll/version.rb', 'lib/rack/jekyll/ext.rb']

 s.extra_rdoc_files = %w[README.markdown]
 s.homepage = "http://github.com/adaoraul/rack-jekyll"
 s.require_paths = %w[lib]
 s.rubyforge_project = 'rack-jekyll'
 s.rubygems_version = '1.3.1'
 s.add_dependency 'jekyll', ">= 1.3"
 s.add_dependency 'rack', "~> 1.5"
 s.add_development_dependency('bacon')
 s.platform = Gem::Platform::RUBY
end

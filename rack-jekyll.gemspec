Gem::Specification.new do |s|
 s.specification_version = 1 if s.respond_to? :specification_version=
 s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
 
 s.name    	= 'rack-jekyll'
 s.version	= '0.1'
 s.description	= "Transform your jekyll based app into a Rack application"
 s.summary	= "rack-jekyll"
 
 s.authors	= ['Bryan Goines']
 s.email	= 'bryan@ffiirree.com'
 
 s.files 	= %w[
			README.markdown
			LICENSE
			lib/rack/jekyll.rb
		  ]
 
 s.extra_rdoc_files	= %w[README.markdown]
 s.has_rdoc = false
 s.homepage = "http://github.com/bry4n/rack-jekyll"
 s.require_paths = %w[lib]
 s.rubyforge_project = 'rack-jekyll'
 s.rubygems_version = '1.3.1'
 s.add_dependency('jekyll')
 s.add_dependency('rack')
 s.platform = Gem::Platform::RUBY
end

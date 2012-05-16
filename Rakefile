require 'rubygems'
require 'rubygems/specification'
require 'rubygems/package_task'
require 'rake/testtask'
#require 'extensions/all'
require_relative 'lib/rack/jekyll'

task :default => :test

desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.pattern = 'test/*.rb'
  t.verbose = true
  t.warning = true
end

desc "Build gem"
task :build do
  sh "gem build rack-jekyll.gemspec"
end

desc "Install gem"
task :install do
  sh "sudo gem install rack-jekyll-#{Rack::Jekyll.version}.gem"
end

desc "Push to rubygems.org"
task :push do
  sh "gem push rack-jekyll-#{Rack::Jekyll.version}.gem"
end

desc "Clean up gem"
task :clean do
  sh "rm *.gem"
end

desc "Run demo"
task :demo do
  puts " ==> Starting demo: http://localhost:3000/"
  Dir.chdir("example") do
    sh "rackup -p 3000"
  end
end

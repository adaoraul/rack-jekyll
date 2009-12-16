task :default => :test

desc "Run all tests"
task :test do
  puts "To do here..."
end

desc "Build gem"
task :build do
  sh "gem build rack-jekyll.gemspec"
end

desc "Install gem"
task :install do
  sh "sudo gem install rack-jekyll-0.1.gem"
end

desc "Push to Gemcutter"
namespace :gem do
  task :push do
    sh "gem push rack-jekyll-0.1.gem"
  end
end

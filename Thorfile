require 'lib/rack/jekyll/version'

class Gem < Thor
  map "-L" => :list

  desc "build", "build a gem"
  def build
    system("gem build rack-jekyll.gemspec")
  end
  
  desc "install", "install gem"
  def install
    system("sudo gem install rack-jekyll-#{Rack::Jekyll.version}.gem")
  end

  desc "clean","clean up gem"
  def clean
    system("rm *.gem")
  end

  desc "push","push gem to gemcutter"
  def push
    system("gem push rack-jekyll-#{Rack::Jekyll.version}.gem")
  end

end

class Git < Thor
  map "-L" => :list
  
  desc "push", "git-push"
  def push
    system("git push")
  end
  
  desc "commit","git-commit"
  def commit
    system("git commit")
  end

  desc "pull","git-pull"
  def pull
    system("git pull origin master")
  end

end

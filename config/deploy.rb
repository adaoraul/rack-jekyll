set :application, "rack-jekyll"
set :user, "bry4n"
set :repository,  "git@github.com:#{user}/#{application}.git"

set :scm, :git
set :scm_username, user
set :runner, user
set :use_sudo, false
set :deploy_via, :checkout
set :branch, "master"
set :git_shallow_clone, 1

default_run_options[:pty] = true

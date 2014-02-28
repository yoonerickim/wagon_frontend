set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require "bundler/capistrano"
require "rvm/capistrano" 
require "capistrano-resque"
require "capistrano-conditional"

set :scm,             :git
set :repository,      "git@bitbucket.org:actinoform/hts-web-app.git"
set :branch,          "origin/master"
set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }
set :deploy_to,       "/home/ec2-user/apps/hts"
set :normalize_asset_timestamps, false
set :user,            "ec2-user"
set :group,           "ec2-user"
set :use_sudo,        false

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_environment["PATH"]         = "/home/ec2-user/.rvm/gems/ruby-1.9.3-p286/bin:/home/ec2-user/.rvm/gems/ruby-1.9.3-p286@global/bin:/home/ec2-user/.rvm/rubies/ruby-1.9.3-p286/bin:/home/ec2-user/.rvm/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin"
default_environment["GEM_HOME"]     = "/home/ec2-user/.rvm/gems/ruby-1.9.3-p286"
default_environment["GEM_PATH"]     = "/home/ec2-user/.rvm/gems/ruby-1.9.3-p286:/home/ec2-user/.rvm/gems/ruby-1.9.3-p286@global"
default_environment["RUBY_VERSION"] = "ruby-1.9.3-p286"

set :rvm_ruby_string, "ruby-1.9.3-p286"

default_run_options[:shell] = 'bash'

after "deploy:stop", "resque:stop"
after "deploy:start", "resque:start"
ConditionalDeploy.register(:resque, :unless => lambda { |changed| changed.all?{|f| f['public/'] || f['config/deploy/'] || f['app/assets/'] || f['app/controllers/'] || f['app/views/'] } }) do
  if fetch(:skip_workers_restart, false) == true
    logger.info "Skipping workers restart because you told me to"	
  else
    after "deploy:restart", "resque:restart"
  end
end

ConditionalDeploy.monitor_migrations(self)

namespace :conditional do 
  desc "Tests to be sure that the newest local and remote git commits match"
  task :ensure_latest_git do
    #skipping this on our version of cap
  end
end



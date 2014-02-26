require 'resque/tasks'

Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }

Rails.env.production? ? Resque.redis.namespace = "production" : Resque.redis.namespace = "staging" 

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'apn_on_rails_tasks'
begin
  require 'vlad'
  Vlad.load(:app => :unicorn, :scm => :git, :web => :nginx)
rescue LoadError
  # do nothing
end

Hitthespot::Application.load_tasks

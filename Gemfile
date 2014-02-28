source 'http://rubygems.org'
#source 'http://0.0.0.0:8808'

####
# DO NOT ENABLE A GEM HERE UNLESS WILL APPROVES IT
####

ruby "1.9.3"

gem 'rails', '3.2.11'
gem 'bcrypt-ruby', '~> 3.0.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'le', '2.0'
#gem 'newrelic_rpm'
gem 'unicorn'
#gem 'mysql2', '0.3.7'
gem 'pg', '0.13.0'
gem 'dragonfly', '0.9.10'
gem 'rack-cache', :require => 'rack/cache'
gem 'state_machine', '1.1.2'
gem 'geokit-rails3', '0.1.5'
#gem 'activemerchant', '1.20.2'
gem 'activemerchant', git: 'git://github.com/nearapogee/active_merchant.git', ref: '22e3b5d742a5bf'
gem 'rabl', '0.6.13'
gem 'yajl-ruby', '1.1.0'
gem 'twilio-ruby', '3.5.1'
gem 'savon', '0.9.7'
gem 'fog', '0.9.0'
gem 'remotipart', '1.0.1'
gem 'declarative_authorization', '0.5.5'
gem 'exception_notification', '2.5.2'
gem 'asset_sync'
gem 'resque', :require => 'resque/server'
gem 'resque_mailer'
gem 'ruby_parser'
gem "rack-timeout"

#gem 'subtledata' -- not using this anymore
gem 'openmenu', '0.2.0', :require => 'openmenu'

# Asset template engines
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'fancybox-rails'

group :demo, :staging, :production do
  gem 'aws-sdk'
end

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
group :development do

  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano-resque', '0.0.7'
  gem 'capistrano-conditional', :require => false # <-- This is important!  
  #gem 'vlad'
  #gem 'vlad-nginx'
  #gem 'vlad-unicorn'
  #gem 'vlad-git'
end

group :development, :test do
  #gem 'pry'
end

group :test do
  gem 'minitest', '2.11.1'
  gem 'fabrication', '1.3.1'
  gem 'factory_girl_rails', '1.6.0' # Phasing out factory_girl infavor of fabrication.
  gem 'timecop', '0.3.5'
  gem 'simplecov', '0.5.4', :require => false
  #gem 'capybara', '~> 1.1.1'
  # gem 'capybara-webkit', :git => 'git://github.com/matthewcalebsmith/capybara-webkit.git'
  #gem 'launchy', '0.4.0'
end

gem 'apn_on_rails'

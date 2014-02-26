require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
#require 'capybara/rails'
#require 'minitest/pride'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  # Public: Parse JSON response.
  # 
  # Returns JSON.
  def json
    begin
      ActiveSupport::JSON.decode @response.body
    rescue MultiJson::DecodeError => exception
      nil
    end
  end
end

#class ActionDispatch::IntegrationTest
#  include Capybara::DSL
#  Capybara.app = Hitthespot::Application
#  Capybara.javascript_driver = :webkit
#end

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  #test "should create a session from email" do
  #  user = Factory.create(:user)
  #  params = {:username => user.email, :password => "password"}
  #  post :create, params
  #  assert_equal user.id, session[:user_id]
  #  assert_redirected_to root_path
  #  assert_equal "Logged in successfully!", flash[:notice]
  #end

  #test "should create a session from phone" do
  #  user = Factory.create(:user)
  #  params = {:username => user.phone, :password => "password"}
  #  post :create, params
  #  assert_equal user.id, session[:user_id]
  #  assert_redirected_to root_path
  #  assert_equal "Logged in successfully!", flash[:notice]
  #end

  #test "should not create a session" do
  #  post :create
  #  assert_nil session[:user_id]
  #  assert_redirected_to root_path
  #  assert_equal "Username or password incorrect.", flash[:alert]
  #end

  #test "should destroy session" do
  #  session[:user_id] = 1
  #  delete :destroy
  #  assert_nil session[:user_id]
  #  assert_equal "Logged out successfully.", flash[:notice]
  #end
end

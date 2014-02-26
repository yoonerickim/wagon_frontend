require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  #test "should get index" do
  #  get :index
  #  assert_response :success
  #end

  #test "should render username/password fields to login if no session" do
  #  session.delete(:user_id)
  #  get :index

  #  assert_select "form[action=#{session_path}][id=new_session]" do
  #    assert_select "input[type=text][name=username]"
  #    assert_select "input[type=password][name=password]"
  #    assert_select "input[type=submit]"
  #  end

  #  assert_select "a[href=#{forgot_password_users_path}]", :text => "Reset Password"
  #  assert_select "a[href=#{new_user_path}]", :text => "Register?"
  #end

  #test "should render render My Account/Logout links if session" do
  #  user = Factory.create(:user)
  #  session[:user_id] = user.id
  #  get :index

  #  assert_select "a[href=#{account_path}]", :text => "My Account"
  #  assert_select "a", :text => "Logout" # TODO add href
  #end

  #test "should render vendor sign up form" do
  #  get :index
  #  
  #  assert_select "form[action=#{vendors_path}]"
  #end

  #test "should get about page" do
  #  get :about
  #  assert_response :success
  #end
  #
  #test "should get contact page" do
  #  get :contact
  #  assert_response :success
  #end

  #test "should get privacy page" do
  #  get :privacy
  #  assert_response :success
  #end

  test "should get terms page" do
    get :terms
    assert_response :success
  end
end

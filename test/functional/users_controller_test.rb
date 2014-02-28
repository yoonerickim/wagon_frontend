require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @params = {:user => {:first_name => "Fred", :last_name => "Flintstone", :email => "fred@flintstones.com", :password => "password", :password_confirmation => "password"}}
  end

  #test "should get new" do
  #  get :new
  #  assert_response :success

  #  assert assigns(:user)

  #  assert_select "form[id=new_user]" do
  #    assert_select "input[type=text][name='user[first_name]']"
  #    assert_select "input[type=text][name='user[last_name]']"
  #    assert_select "input[type=text][name='user[email]']"
  #    assert_select "input[type=password][name='user[password]']"
  #    assert_select "input[type=password][name='user[password_confirmation]']"
  #    assert_select "input[type=submit]"
  #  end
  #end

  #test "should create a user" do
  #  assert_difference "User.count" do
  #    post :create, @params
  #  end
  #  assert session[:user_id]
  #  assert_redirected_to account_path
  #  assert_equal 'Welcome to Hit the Spot!', flash[:notice]
  #end

  #test "should fail to create a user" do
  #  assert_difference "User.count", 0 do
  #    post :create
  #  end
  #  assert_template 'new'
  #  assert_equal "Ooops! There might be an error!", flash[:alert]
  #end

  #test "should get show" do
  #  user = Factory.create :user
  #  get :show, :id => user.id
  #  assert_response :success
  #end

  #test "should get forgot_password" do
  #  get :password
  #  assert_response :success

  #  assert_select "form[method=post][action=#{reset_password_users_path}]" do
  #    assert_select "input[type=text][name=username]"
  #    assert_select "input[type=submit]"
  #  end
  #end

  #test "should reset password with email" do
  #  user = Factory.create(:user)
  #  assert_difference "ActionMailer::Base.deliveries.count" do
  #    post :reset, { :username => user.email }
  #  end
  #  assert_redirected_to root_path
  #  assert_equal "Email with password reset instructions has been sent!", flash[:notice]
  #end

  #test "should reset password with phone" do
  #  user = Factory.create(:user)
  #  assert_difference "ActionMailer::Base.deliveries.count" do
  #    post :reset, { :username => user.phone }
  #  end
  #  assert_redirected_to root_path
  #  assert_equal "Email with password reset instructions has been sent!", flash[:notice]
  #end
end

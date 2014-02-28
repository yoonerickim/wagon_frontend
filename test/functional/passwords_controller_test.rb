require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  def setup
    @user = Factory.create :user
    @user.password_reset_token = SecureRandom.urlsafe_base64(64)
    @user.password_reset_sent_at = Time.zone.now - 5.minutes
    @user.save!

    @update_params = {
      :id => @user.password_reset_token, 
      :user => { :password => "new_password", :password_confirmation => 'new_password'} 
    }
  end

  #test "should get edit" do
  #  get :edit, :id => @user.password_reset_token
  #  assert_response :success

  #  assert assigns(:user)

  #  assert_select "form[action=#{password_path(@user.password_reset_token)}]" do
  #    assert_select "input[type=password][name='user[password]']"
  #    assert_select "input[type=password][name='user[password_confirmation]']"
  #    assert_select "input[type=submit][value='Update Password']"
  #  end
  #end

  #test "should update password" do
  #  put :update, @update_params

  #  assert_redirected_to user_path(@user)
  #  assert_equal "Password successfully updated.", flash[:notice]
  #  assert_equal @user.id, session[:user_id]
  #end

  #test "should not update password with bad token" do
  #  put :update, @update_params.merge!(:id => "wrong!")

  #  assert_redirected_to root_path
  #  assert_nil session[:user_id]
  #end

  #test "should not update password with expired token" do
  #  @user.password_reset_sent_at = Time.zone.now - 1.day
  #  @user.save!
  #  put :update, @update_params

  #  assert_redirected_to root_path
  #  assert_equal "Password reset request has expired.", flash[:alert]
  #  assert_nil session[:user_id]
  #end

  #test "should not update password with form error" do
  #  @update_params[:user].merge!(:password_confirmation => "wrong!")
  #  put :update, @update_params

  #  assert_nil session[:user_id]
  #  assert_template 'edit'
  #end

end

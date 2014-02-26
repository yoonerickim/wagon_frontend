class PasswordsController < ApplicationController
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 1.hours.ago
      @user.update_attributes(:password_reset_token => nil, :password_reset_sent_at => nil)
      redirect_to root_path, :alert => "Password reset request has expired."
    elsif @user.update_attributes(params[:user])
      @user.update_attributes(:password_reset_token => nil, :password_reset_sent_at => nil)
      session[:user_id] = @user.id
      flash.notice = "Password successfully updated."
      if session[:placed_order].present?
        redirect_to checkout_order_path
      else
        redirect_to dashboard_account_path
      end
    else
      render 'edit'
    end
  end
end

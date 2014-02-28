class UsersController < ApplicationController
  force_ssl
  before_filter :find_current_user, :only => [:show, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id

      respond_to do |format|
        format.html { redirect_to dashboard_path, :notice => "Welcome to Hit the Spot!" }
        format.js { flash.now.notice = "Please check your email for a confirmation to proceed!" }
      end
    else
      flash.now.alert = "Ooops! There might be an error!"
      respond_to do |format|
        format.html { render 'new' }
        format.js { render 'new' }
      end
    end
  end

  # Reset users password
  #
  def reset
    user = User.find_by_email(params[:username]) || User.find_by_cell_phone(params[:username])
    user.send_password_reset if user
    redirect_to login_path, :notice => "Email with password reset instructions has been sent!"
  end

  # Check of a user exists in the order edit page.
  #
  def check
    @user = User.find_by_email(params[:username]) || User.find_by_cell_phone(params[:username])
    respond_to do |format|
      format.js {}
    end
  end

  # Public: Set the location of the pin in the user's session.
  #
  def pin
    session[:pin_lat] = params[:lat]
    session[:pin_lng] = params[:lng]
    session[:pin_address] = params[:address]
    head :accepted
  end

  private

  def find_current_user
    @user = User.find_by_id(params[:id]) || current_user!
  end
end

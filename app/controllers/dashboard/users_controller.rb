class Dashboard::UsersController < ApplicationController
  force_ssl
  before_filter :find_current_user, only: [:edit, :update, :update_password, :update_contractor]
  filter_access_to :all, attribute_check: true

  def edit
    @title = 'Edit Your Profile | Hit The Spot'
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Profile Updated'
      redirect_to dashboard_account_url(protocol: https)
    else
      render 'edit'
    end
  end

  def update_password
    if @user.authenticate(params[:current_password])
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Password Updated'
        redirect_to dashboard_account_url(protocol: https)
      else
        flash.now[:alert] = "Please fix password errors below."
        render 'edit'
      end
    else
      flash.now[:alert] = "Current password must be correct."
      render 'edit'
    end
  end

  def update_contractor
    if @user.update_attributes(params[:user])
      flash.now[:notice] = 'Details Updated'
    else
      flash.now[:alert] = 'Oops. There was an error.'
    end
  end

  private

  def find_current_user
    @user = User.find_by_id(params[:id]) || current_user!
  end
end

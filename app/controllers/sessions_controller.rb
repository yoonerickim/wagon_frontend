class SessionsController < ApplicationController

  def create
    if params[:username] =~ /@/
      user = User.find_by_email(params[:username]) || User.find_by_cell_phone(params[:username])
    else
      user = User.find_by_cell_phone(params[:username]) || User.find_by_email(params[:username])
    end

    if user.present? && user.authenticate(params[:password])
      clear_live_location!
      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully!"

      respond_to do |format|
        format.html do
          redirect_url = session.delete :unauthorized_url
          if redirect_url.present?
            redirect_to redirect_url
          else
            redirect_to dashboard_path
          end
        end
        format.js # order confirmation (edit) page
      end
    else
      flash.now[:alert] = "Email or password incorrect. Please try again."
      
      respond_to do |format|
        format.html { render :action => :new }
        format.js # order confirmation (edit) page
      end
    end
  end

  def destroy
    session.delete(:user_id) if session[:user_id]
    clear_live_location!
    redirect_to login_path, :notice => "Logged out successfully."
  end

end

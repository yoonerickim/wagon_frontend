class DashboardController < ApplicationController
  force_ssl
  filter_access_to :all

  def index
    #if current_user.has_vendors_or_locations?
    #  redirect_to dashboard_vendors_path
    #else
      redirect_to dashboard_account_path
    #end
  end
  
end

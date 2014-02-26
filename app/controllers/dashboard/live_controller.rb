class Dashboard::LiveController < ApplicationController

  before_filter :authorize

  def index; end

  private

  def authorize
    redirect_to login_url unless live_location
  end

end

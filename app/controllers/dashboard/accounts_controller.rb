class Dashboard::AccountsController < ApplicationController
  force_ssl
  filter_access_to :all

  def show; end
end

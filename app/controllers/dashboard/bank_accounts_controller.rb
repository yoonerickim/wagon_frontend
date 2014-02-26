class Dashboard::BankAccountsController < ApplicationController
  filter_access_to :all

  def new
    @bank_account = BankAccount.new(location_id: params[:location_id])
    render 'edit', format: [:html], layout: false
  end

  def create
    @bank_account = BankAccount.new(params[:bank_account])
    @bank_account.save
    render 'update'
  end

  def edit
    @bank_account = BankAccount.find(params[:id])
    render format: [:html], layout: false
  end

  def update
    @bank_account = BankAccount.find(params[:id])
    @bank_account.update_attributes(params[:bank_account])
  end
end

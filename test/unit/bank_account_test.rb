require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @location = Factory.build(:location)
    @location.integrate_pos = false
    @account = @location.build_bank_account(:institution => "Mighty Bank", :account => "123456789012", :routing => "111000025", :account_type => 'checking')
  end

  test "valid with valid attributes" do
    assert @account.valid?, @account.errors.inspect
  end

  #test "valid with blank attributes if required is false" do
  #  @account.required = false
  #  @account.institution = nil
  #  @account.account = nil
  #  @account.routing = nil
  #  assert @account.valid?
  #end

  #test "valid with blank attributes if locations integrate_pos is true" do
  #  @location.integrate_pos = true
  #  @location.save!

  #  @account.institution = nil
  #  @account.account = nil
  #  @account.routing = nil
  #  assert @account.valid?
  #end

  #test "invalid without institution" do
  #  @account.institution = nil
  #  assert !@account.valid?
  #end

  #test "invalid without account" do
  #  @account.account = nil
  #  assert !@account.valid?
  #end

  #test "invalid without numeric account" do
  #  @account.account = "123asd789012"
  #  assert !@account.valid?
  #end

  #test "invalid without routing" do
  #  @account.routing = nil
  #  assert !@account.valid?
  #end

  #test "invalid without numeric routing" do
  #  @account.routing = "123qwe789"
  #  assert !@account.valid?
  #end
end

require 'test_helper'

class SpeedMenuAccountTest < ActiveSupport::TestCase
  def setup
    @location = Factory.build(:location)
    @location.integrate_pos = true
    @account = @location.build_pos_account(make:"Mighty Cash", model:"Cash 2000")
  end

  test "valid with valid attributes" do
    assert @account.valid?
  end

  test "valid with blank attributes if required is false" do
    @account.required = false
    @account.make = nil
    @account.model = nil
    assert @account.valid?
  end

  test "valid with blank attributes if location integrate_pos is false" do
    @location.integrate_pos = false
    @location.save!

    @account.make = nil
    @account.model = nil
    assert @account.valid?
  end

  #test "invalid without make" do
  #  @account.make = nil
  #  assert !@account.valid?
  #end

  #test "invalid without model" do
  #  @account.model = nil
  #  assert !@account.valid?
  #end
end

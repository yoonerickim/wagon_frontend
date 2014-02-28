require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  def setup
    @address = Address.new(street1:"1234 Street Way", city:"Gotham", state:"NY", zip:"12345")
  end

  test "valid with valid attributes" do
    assert @address.valid?
  end

  #test "invalid without street1" do
  #  @address.street1 = nil
  #  assert !@address.valid?
  #end

  #test "invalid without city" do
  #  @address.city = nil
  #  assert !@address.valid?
  #end

  #test "invalid without state" do
  #  @address.state = nil
  #  assert !@address.valid?
  #end

  #test "invalid without zip" do
  #  @address.zip = nil
  #  assert !@address.valid?
  #end

  #test "invalid without numeric zip" do
  #  @address.zip = "abcde"
  #  assert !@address.valid?
  #end
end

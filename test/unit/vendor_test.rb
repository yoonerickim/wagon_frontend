require 'test_helper'

class VendorTest < ActiveSupport::TestCase
  def setup
    @vendor = Vendor.new(:name => "Wilma's Diner")
  end

  test "valid with valid attributes" do
    assert @vendor.valid?
  end

  test "invalid without name" do
    @vendor.name = nil
    assert !@vendor.valid?
  end

  #test "creates registration token before_create" do
  #  @vendor.save!
  #  assert @vendor.registration_token
  #end

  #test "invalid with more than one user on create" do
  #  2.times do
  #    assignment = @vendor.assignments.build
  #    assignment.user = Factory.build(:user)
  #  end
  #  assert !@vendor.valid?
  #end

  test "deletes registration_token on update" do
    @vendor.save!

    @vendor.update_attributes!(:name => "blah")
    assert_nil @vendor.registration_token
  end
end

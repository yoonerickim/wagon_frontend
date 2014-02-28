require 'test_helper'

class BillingMethodTest < ActiveSupport::TestCase
  def setup
    @location = Factory.build(:location)
    @method = BillingMethod.new(:card_number => "1234123412341234")
  end

  test "valid with valid attributes" do
    assert @method.valid?
  end

  test "required is true after initialize" do
    assert @method.required
  end

  #test "invalid without card_number on create" do
  #  @method.card_number = nil
  #  assert !@method.valid?
  #end

  test "valid with blank attributes on create with required false" do
    @method.required = false
    @method.card_number = nil
    assert @method.new_record?
    assert @method.valid?
  end

  test "valid with blank attributes on create with location integrate_pos false" do
    @location.integrate_pos = false
    @location.save!
    @method = @location.build_billing_method
    @method.card_number = nil
    assert @method.required
    assert @method.valid?
  end

  test "valid without card_number on update" do
    @method.save
    @method.card_number = nil
    assert @method.valid?
  end

end

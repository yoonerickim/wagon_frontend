require 'test_helper'

class MenuSizeTest < ActiveSupport::TestCase
  def setup
    @menu_size = MenuSize.new(:name => "Small", :price => 799)
  end

  test "valid with valid attributes" do
    assert @menu_size.valid?
  end

  test "invalid without name" do
    @menu_size.name = nil
    assert !@menu_size.valid?
  end

  test "invalid without price" do
    @menu_size.price = nil
    assert !@menu_size.valid?
  end

  test "#dollars= sets price in cents" do
    @menu_size.dollars = "7.35"
    assert_equal 735, @menu_size.price
    assert @menu_size.valid?
  end

  test "#dollars gets price as float" do
    assert_equal 7.99, @menu_size.dollars
  end
end

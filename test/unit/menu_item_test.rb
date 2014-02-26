require 'test_helper'

class MenuItemTest < ActiveSupport::TestCase
  def setup
    @menu_item = MenuItem.new :name => "Sandwich", :price => 799
  end

  test "valid with valid attributes" do
    assert @menu_item.valid?
  end

  test "invalid without name" do
    @menu_item.name = nil
    assert !@menu_item.valid?
  end

  #test "invalid without price" do
  #  @menu_item.price = nil
  #  assert !@menu_item.valid?
  #end

  test "valid without price if at least 1 menu_size" do
    @menu_item.sizes.build(:name => 'Small', :price => 199)
    @menu_item.save!
    assert_equal 1, @menu_item.sizes.count
    @menu_item.price = nil
    assert @menu_item.valid?
  end

  test "#dollars= sets price in cents" do
    @menu_item.dollars = "7.35"
    assert_equal 735, @menu_item.price
    assert @menu_item.valid?
  end

  test "#dollars gets price as float" do
    assert_equal 7.99, @menu_item.dollars
  end
end

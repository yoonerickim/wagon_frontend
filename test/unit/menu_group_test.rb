require 'test_helper'

class MenuGroupTest < ActiveSupport::TestCase
  def setup
    @group = MenuGroup.new name: "Dessert"
  end

  test "valid with valid attributes" do
    assert @group.valid?
  end

  test "invalid without name" do
    @group.name = nil
    assert !@group.valid?
  end
end

require 'test_helper'

class MenuTest < ActiveSupport::TestCase
  def setup
    @menu = Menu.new(:name => "Late Night")
  end

  test "valid with valid attributes" do
    assert @menu.valid?
  end

  test "invalid without name" do
    @menu.name = nil
    assert !@menu.valid?
  end
end

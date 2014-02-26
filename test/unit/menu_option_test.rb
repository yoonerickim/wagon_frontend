require 'test_helper'

class MenuOptionTest < ActiveSupport::TestCase
  def setup
    @option = MenuOption.new name: "Breads"
  end
  
  test "valid with valid options" do
    assert @option.valid?
  end

  test "invalid without name" do
    @option.name = nil
    assert !@option.valid?
  end
end

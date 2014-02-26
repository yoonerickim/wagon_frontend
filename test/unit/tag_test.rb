require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = Tag.new(name:"happy-hour")
  end
  
  test "valid with valid attributes" do
    assert @tag.valid?
  end

  test "invalid without name" do
    @tag.name = nil
    assert !@tag.valid?
  end
end

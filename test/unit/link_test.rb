require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  def setup
    @link = Link.new(name:"Twitter", value:"http://twitter.com/#!/tenderlove")
  end

  test "valid with valid attributes" do
    assert @link.valid?
  end

  test "valid without name" do
    @link.name = nil
    assert @link.valid?
  end

  test "valid with nil value" do
    @link.value = nil
    assert @link.valid?, @link.errors.full_messages.join(', ')
  end

  test "valid without value" do
    @link.value = ""
    assert @link.valid?, @link.errors.full_messages.join(', ')
  end

  #test "invalid without valid address value" do
  #  @link.value = "something else"
  #  assert !@link.valid?, @link.errors.full_messages.join(', ')
  #end

  #test "VENDOR links" do
  #  ['Website', 'Facebook', 'Twitter'].each do |link|
  #    assert Link::VENDOR_NAMES.include?(link), "Missing #{link} url."
  #  end
  #  assert_equal 3, Link::VENDOR_NAMES.length
  #end

  test "LOCATION Links" do
    ['Google Places', 'Yelp', 'Foursquare', 'Urbanspoon'].each do |link|
      assert Link::LOCATION_NAMES.include?(link), "Missing #{link} url."
    end
    assert_equal 4, Link::LOCATION_NAMES.length
  end

  test "OPTIONAL Links" do
    ['Review', 'Article', 'Other'].each do |link|
      assert Link::OPTIONAL_NAMES.include?(link), "Missing #{link} url."
    end
    assert_equal 3, Link::OPTIONAL_NAMES.length
  end

end

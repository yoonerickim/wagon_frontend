require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  class MyLocation < Location
    def get_xml(url)
      File.open(File.dirname(__FILE__) + "/../xml/met_grill.xml", 'r') { |file| file.read }
    end
  end

  def setup
    @location = MyLocation.new(dine_in:true, phone:"123-123-1234", time_zone: "Pacific Time (US & Canada)")
  end

  test "valid with valid attributes" do
    assert @location.valid?
  end

  test "invalid without phone" do
    @location.phone = nil
    assert !@location.valid?
  end

  test "invalid if menu url not valid" do
    @location.menu_url = "not a url5!"
    assert !@location.valid?
  end

  test "invalid if openmenu_url not valid" do
    @location.openmenu_url = "not a url5!"
    assert !@location.valid?
  end

  test "invalid with out at least one delivery type selected" do
    @location.dine_in = false
    @location.take_out = false
    @location.address_delivery = false
    @location.spot_delivery = false

    assert !@location.valid?
  end

  test "save calls #parse_menu" do
    @location.openmenu_url = "http://openmenu.com/menu/20ee53fe-15bb-11e0-b40e-0018512e6b26"
    @location.save!

    assert @location.menus.count > 0
  end

  test "tag_ids assigns tags through tag_links" do
    t1 = Tag.create(:name => "Tag1")
    t2 = Tag.create(:name => "Tag2")
    @location.tag_ids = [t1.id, t2.id]
    @location.save
    assert_equal 2, @location.tags.count
  end

  test "without any hours, we are always open" do
    assert_equal true, @location.open?(0)
  end

  test "its closed before it is open" do
    weekday = Time.now.utc.in_time_zone(@location.time_zone).strftime("%A")
    the_hour = Hour.create(:day => weekday, :closed => false, :open_at => Time.now.utc.midnight + 600,
                           :close_at => Time.now.utc.midnight + 700);
    @location.hours << the_hour
    @location.use_hours_for_delivery_hours = true
    @location.save
    assert_equal false, @location.open?(599)
    assert_equal false, @location.delivering?(599)
  end

  test "its open if we are within the hours" do
    weekday = Time.now.utc.in_time_zone(@location.time_zone).strftime("%A")
    the_hour = Hour.create(:day => weekday, :closed => false, :open_at => Time.now.utc.midnight + 600,
                           :close_at => Time.now.utc.midnight + 700);
    @location.hours << the_hour
    @location.use_hours_for_delivery_hours = true
    @location.save
    assert_equal true, @location.open?(650)
    assert_equal true, @location.delivering?(650)
  end

  test "its closed if we are after hours" do
    weekday = Time.now.utc.in_time_zone(@location.time_zone).strftime("%A")
    the_hour = Hour.create(:day => weekday, :closed => false, :open_at => Time.now.utc.midnight + 600,
                           :close_at => Time.now.utc.midnight + 700);
    @location.hours << the_hour
    @location.use_hours_for_delivery_hours = true
    @location.save
    assert_equal false, @location.open?(700)
    assert_equal false, @location.delivering?(700)
  end

  test "its closed if its closed for the day" do
    weekday = Time.now.utc.in_time_zone(@location.time_zone).strftime("%A")
    the_hour = Hour.create(:day => weekday, :closed => true, :open_at => Time.now.utc.midnight + 600,
                           :close_at => Time.now.utc.midnight + 700);
    @location.hours << the_hour
    @location.use_hours_for_delivery_hours = true
    @location.save
    assert_equal false, @location.open?(650)
    assert_equal false, @location.delivering?(650)
  end

  test "delivery follows its own hours" do
    weekday = Time.now.utc.in_time_zone(@location.time_zone).strftime("%A")
    the_hour = Hour.create(:day => weekday, :closed => true, :open_at => Time.now.utc.midnight + 600,
                           :close_at => Time.now.utc.midnight + 700);
    @location.hours << the_hour
    delivery_hour = DeliveryHour.create(:day => weekday, :closed => false, :open_at => Time.now.utc.midnight + 600,
                                        :close_at => Time.now.utc.midnight + 700
                                       );
                                       @location.delivery_hour_ids = [delivery_hour.id]
                                       @location.use_hours_for_delivery_hours = false
                                       @location.save
                                       assert_equal false, @location.open?(650)
                                       assert_equal true, @location.delivering?(650)
  end

  test "time_offset is available" do
    assert @location.time_offset
  end

  test "#open? returns true/false when called with out arguement" do
    @location.use_hours_for_delivery_hours = true
    [true, false].include? @location.open?
    @location.use_hours_for_delivery_hours = false
    [true, false].include? @location.open?
  end

  test "#delivering? returns true/false when called with out arguement" do
    @location.use_hours_for_delivery_hours = true
    [true, false].include? @location.delivering?
    @location.use_hours_for_delivery_hours = false
    [true, false].include? @location.delivering?
  end
end

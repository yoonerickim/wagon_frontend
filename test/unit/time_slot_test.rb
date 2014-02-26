require 'test_helper'

class TimeSlotTest < ActiveSupport::TestCase
  test "intersection with later time is narrowed" do
      first = TimeSlot.create(:open_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create(:open_at => Time.now.utc.midnight + 200);
      result = first.intersection(second)
      assert_equal 200, result.open_at.seconds_since_midnight
  end

  test "intersection with earlier time is not narrowed" do
      first = TimeSlot.create(:open_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create(:open_at => Time.now.utc.midnight + 50);
      result = first.intersection(second)
      assert_equal 100, result.open_at.seconds_since_midnight
  end

  test "no opening time means always open" do
      first = TimeSlot.create(:open_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create();
      result = first.intersection(second)
      assert_equal 100, result.open_at.seconds_since_midnight
  end

  test "intersection handles no opening time" do
      first = TimeSlot.create();
      second = TimeSlot.create(:open_at => Time.now.utc.midnight + 50);
      result = first.intersection(second)
      assert_equal 50, result.open_at.seconds_since_midnight
  end

  test "intersection with later closing time is narrowed" do
      first = TimeSlot.create(:close_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create(:close_at => Time.now.utc.midnight + 200);
      result = first.intersection(second)
      assert_equal 100, result.close_at.seconds_since_midnight
  end

  test "intersection with earlier closing time is not narrowed" do
      first = TimeSlot.create(:close_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create(:close_at => Time.now.utc.midnight + 50);
      result = first.intersection(second)
      assert_equal 50, result.close_at.seconds_since_midnight
  end

  test "no closing time means always close" do
      first = TimeSlot.create(:close_at => Time.now.utc.midnight + 100);
      second = TimeSlot.create();
      result = first.intersection(second)
      assert_equal 100, result.close_at.seconds_since_midnight
  end

  test "intersection handles no closing time" do
      first = TimeSlot.create();
      second = TimeSlot.create(:close_at => Time.now.utc.midnight + 50);
      result = first.intersection(second)
      assert_equal 50, result.close_at.seconds_since_midnight
  end

  test "intersection on closed produces closed" do
      first = TimeSlot.create(:closed => true);
      second = TimeSlot.create(:closed => false);
      assert_equal true, first.intersection(second).closed
  end

  test "intersection on open produces open" do
      first = TimeSlot.create(:closed => false);
      second = TimeSlot.create(:closed => false);
      assert_equal false, first.intersection(second).closed
  end
end

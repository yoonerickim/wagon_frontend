# TimeSlot
#
# Fields:
# day - string name - TimeSlot::DAYS
# closed - true if closed
# open - time
# close - time
#
class TimeSlot < ActiveRecord::Base
  belongs_to :location
  belongs_to :user

  DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

  validates :day, inclusion: { in: DAYS }

  # Public: returns an Hour which is always open
  def self.always_open
    hour = TimeSlot.new
    hour.closed = false
    hour
  end

  # Public: test if time is within the hours
  #
  # seconds_since_midnight - seconds since midnight in the local time zone
  #
  def in_hours?(seconds_since_midnight)
    return false if closed
    if open_at.present? && open_at.seconds_since_midnight >= seconds_since_midnight
      return false
    end
    if close_at.present? && seconds_since_midnight >= close_at.seconds_since_midnight
      return false
    end
    true
  end

  def intersection(time_slot)
    new_time_slot = TimeSlot.new
    if time_slot.open_at.present?
      if open_at.present?
        starting_seconds = [open_at.seconds_since_midnight, time_slot.open_at.seconds_since_midnight].max
        new_time_slot.open_at = Time.now.utc.midnight + starting_seconds
      else
        new_time_slot.open_at = time_slot.open_at
      end
    else
      new_time_slot.open_at = open_at
    end

    if time_slot.close_at.present?
      if close_at.present?
        starting_seconds = [close_at.seconds_since_midnight, time_slot.close_at.seconds_since_midnight].min
        new_time_slot.close_at = Time.now.utc.midnight + starting_seconds
      else
        new_time_slot.close_at = time_slot.close_at
      end
    else
      new_time_slot.close_at = close_at
    end

    new_time_slot.closed = closed or time_slot.closed

    new_time_slot
  end
end

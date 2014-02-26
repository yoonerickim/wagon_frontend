class Menu < ActiveRecord::Base
  belongs_to :location

  has_many :groups, class_name: 'MenuGroup', dependent: :destroy, autosave: true
  has_many :items, :through => :groups, :class_name => 'MenuItem'

  validates :name, :presence => true

  accepts_nested_attributes_for :groups, allow_destroy: true

  def available_hours
    mytimes = TimeSlot.new

    mytimes.open_at = start_at
    mytimes.close_at = end_at
    location.todays_hours.intersection(mytimes)
  end

  def delivery_hours
    mytimes = TimeSlot.new

    mytimes.open_at = start_at
    mytimes.close_at = end_at
    location.todays_hours.intersection(mytimes)
  end

  # Public: Test if menu is between start and end times.
  #
  # If times are not specified returns true.
  #
  # Returns true if active.
  def active?
    if location.present?
      now = Time.now.utc.in_time_zone(location.time_zone).seconds_since_midnight
      if self.start_at.present? && self.start_at.seconds_since_midnight >= now
        return false
      end
      if self.end_at.present? && now >= self.end_at.seconds_since_midnight
        return false
      end
    end
    true
  end

  def show_for? order
    if order.delivery_order?
      if location.delivering?
        return true if active?
      elsif !location.open?
        return true
      end
    else
      if location.open?
        return true if active?
      else
        return true # Display all menus if closed
      end
    end
  end

end

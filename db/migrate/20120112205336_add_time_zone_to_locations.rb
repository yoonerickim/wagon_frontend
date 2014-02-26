class AddTimeZoneToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :time_zone, :string, default: Location::PACIFIC_TIME
  end
end

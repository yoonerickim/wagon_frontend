class AddDeliveryRadiusToLocations < ActiveRecord::Migration
  def change
    add_column(:locations, :delivery_radius, :float)
    add_column(:locations, :delivery_boundries, :text)
  end
end

class AddMinimumAndDeliveryFeeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :delivery_minimum, :integer, default: 500
    add_column :locations, :delivery_fee, :integer, default: 0
  end
end

class AddUseHoursForDeliveryHoursToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :use_hours_for_delivery_hours, :boolean
  end
end

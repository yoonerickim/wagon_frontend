class AddDeliveryToTimeSlots < ActiveRecord::Migration
  def change
    add_column :time_slots, :delivery, :boolean, default: false
  end
end

class CreateDeliverySpots < ActiveRecord::Migration
  def change
    create_table :delivery_spots do |t|
      t.float :lat
      t.float :lng
      t.string :reverse_address
      t.boolean :use_reverse, default: true
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.integer :order_id

      t.timestamps
    end
  end
end

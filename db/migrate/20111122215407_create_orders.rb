class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :location_id

      t.timestamps
    end

    add_index :orders, [:user_id, :location_id], :unique => true
  end
end

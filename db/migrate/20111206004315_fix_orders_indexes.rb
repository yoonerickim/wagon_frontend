class FixOrdersIndexes < ActiveRecord::Migration
  def up
    remove_index :orders, :column => [:user_id, :location_id]
    add_index :orders, :user_id
    add_index :orders, :location_id
  end

  def down
    remove_index :orders, :location_id
    remove_index :orders, :user_id
    add_index :orders, [:user_id, :location_id], :unique => true
  end
end

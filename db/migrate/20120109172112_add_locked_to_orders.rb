class AddLockedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :locked, :boolean, default: false
    add_column :orders, :line_items_locked, :boolean, default: false
  end
end

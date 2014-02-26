class AddTimeFieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :submitted_at, :datetime
    add_column :orders, :confirmed_at, :datetime
    add_column :orders, :fulfilled_at, :datetime
    add_column :orders, :reversed_at, :datetime
  end
end

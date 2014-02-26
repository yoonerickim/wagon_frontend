class RemoveReversedAtFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :reversed_at
  end

  def down
    add_column :orders, :reversed_at, :datetime
  end
end

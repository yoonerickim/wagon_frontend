class RemoveOrderTypeIdColumnFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :order_type_id
  end

  def down
    add_column :orders, :order_type_id, :integer
  end
end

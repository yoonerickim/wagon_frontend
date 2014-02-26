class ChangeOrderTypeToStringInOrders < ActiveRecord::Migration
  def up
    change_column :orders, :order_type, :string
  end

  def down
    change_column :orders, :order_type, :integer
  end
end

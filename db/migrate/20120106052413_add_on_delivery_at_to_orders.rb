class AddOnDeliveryAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :on_delivery_at, :datetime
  end
end

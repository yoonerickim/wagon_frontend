class AddUseCustomerGeometryToOrders < ActiveRecord::Migration
  def change
    add_column(:orders, :use_customer_geometry, :boolean, :default => false)
  end
end

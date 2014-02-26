class AddTipTermsAndDeliveryMethodToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip, :integer, :default => 15
    add_column :orders, :terms, :boolean, :default => false
    add_column :orders, :order_type_id, :integer
  end
end

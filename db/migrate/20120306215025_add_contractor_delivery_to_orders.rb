class AddContractorDeliveryToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contractor_delivery, :boolean, default: false
  end
end

class AddContractorIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contractor_id, :integer
  end
end

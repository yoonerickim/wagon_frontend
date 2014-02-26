class AddStatesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :state, :string
    add_column :orders, :pay_state, :string
  end
end

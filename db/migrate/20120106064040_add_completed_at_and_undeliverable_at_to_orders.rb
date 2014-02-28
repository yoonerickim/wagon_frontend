class AddCompletedAtAndUndeliverableAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :undeliverable_at, :datetime
    add_column :orders, :completed_at, :datetime
  end
end

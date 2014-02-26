class AddSavedCardIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :saved_card_id, :integer
  end
end

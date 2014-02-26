class AddConfirmNotesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :confirm_notes, :text

  end
end

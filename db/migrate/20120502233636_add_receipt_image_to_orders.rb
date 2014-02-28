class AddReceiptImageToOrders < ActiveRecord::Migration
  def change
    add_column(:orders, :receipt_image_uid, :string)
    add_column(:orders, :receipt_image_name, :string)
  end
end

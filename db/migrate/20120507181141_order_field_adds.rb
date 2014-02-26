class OrderFieldAdds < ActiveRecord::Migration
  def change
    add_column(:orders, :location_name_original, :string)
    add_column(:orders, :custom_order_body_original, :text)
  end
end

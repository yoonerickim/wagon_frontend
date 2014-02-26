class AddStuffToOrders < ActiveRecord::Migration
  def change
    add_column(:orders, :location_name, :string)
    add_column(:orders, :approx_cost, :integer)
    add_column(:orders, :actual_cost, :integer)
    add_column(:orders, :custom_location_id, :integer)
    add_column(:orders, :custom_order_body, :text)
    
    create_table :custom_locations do |t|
      t.string :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
      
  end
end

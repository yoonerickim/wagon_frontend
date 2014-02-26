class FixCostTypeInOrders < ActiveRecord::Migration
  def up
    change_column(:orders, :approx_cost, :float)
    change_column(:orders, :actual_cost, :float)   
    add_column(:custom_locations, :reverse_address, :string) 
  end

  def down
    change_column(:orders, :approx_cost, :integer)
    change_column(:orders, :actual_cost, :integer)    
    remove_column(:custom_locations, :reverse_address)
  end
end

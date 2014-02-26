class ChangeMoniesToInts < ActiveRecord::Migration
  def up
    change_column(:orders, :approx_cost, :integer)
    change_column(:orders, :actual_cost, :integer)    
  end

  def down
    change_column(:orders, :approx_cost, :float)
    change_column(:orders, :actual_cost, :float)    
  end
end

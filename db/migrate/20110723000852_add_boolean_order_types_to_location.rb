class AddBooleanOrderTypesToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :dine_in, :boolean
    add_column :locations, :take_out, :boolean
    add_column :locations, :address_delivery, :boolean
    add_column :locations, :gps_delivery, :boolean
  end
end

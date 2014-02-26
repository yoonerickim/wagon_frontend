class AddFieldsToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :legal_name, :string
    add_column :vendors, :description, :text
  end
end

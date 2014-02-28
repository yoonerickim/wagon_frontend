class AddRegistrationFieldsToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :registration_token, :string
    
    add_index :vendors, :registration_token,              :unique => true
  end
end

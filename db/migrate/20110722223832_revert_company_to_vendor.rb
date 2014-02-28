class RevertCompanyToVendor < ActiveRecord::Migration
  def up
    rename_table :companies, :vendors
    rename_column :assignments, :company_id, :vendor_id
    rename_column :locations, :company_id, :vendor_id
  end

  def down
    rename_table :vendors, :companies
    rename_column :assignments, :vendor_id, :company_id
    rename_column :locations, :vendor_id, :company_id
  end
end

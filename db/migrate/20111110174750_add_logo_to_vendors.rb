class AddLogoToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :logo_image_uid, :string
    add_column :vendors, :logo_image_name, :string
  end
end

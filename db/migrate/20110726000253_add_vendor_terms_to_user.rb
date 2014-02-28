class AddVendorTermsToUser < ActiveRecord::Migration
  def change
    add_column :users, :vendor_terms, :boolean,   :default => false
  end
end

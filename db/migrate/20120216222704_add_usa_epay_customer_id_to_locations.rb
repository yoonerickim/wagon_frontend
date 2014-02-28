class AddUsaEpayCustomerIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :usa_epay_customer_id, :integer
  end
end

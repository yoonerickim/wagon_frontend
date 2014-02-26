class AddUsaEpayCustomerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :usa_epay_customer_id, :integer
  end
end

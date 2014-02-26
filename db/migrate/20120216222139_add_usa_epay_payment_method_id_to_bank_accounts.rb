class AddUsaEpayPaymentMethodIdToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :usa_epay_payment_method_id, :integer
    rename_column :bank_accounts, :account, :last_four
    remove_column :bank_accounts, :routing
  end
end

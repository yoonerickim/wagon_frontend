class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :institution
      t.string :account
      t.string :routing
      t.integer :location_id

      t.timestamps
    end
  end
end

class CreateBillingMethods < ActiveRecord::Migration
  def change
    create_table :billing_methods do |t|
      t.string :masked_number
      t.date :card_expiration
      t.string :card_type
      t.string :account_holder
      t.integer :location_id

      t.timestamps
    end
  end
end

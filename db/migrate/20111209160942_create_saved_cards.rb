class CreateSavedCards < ActiveRecord::Migration
  def change
    create_table :saved_cards do |t|
      t.string :hash
      t.integer :usa_epay_payment_method_id
      t.date :expires_on
      t.string :first_name
      t.string :last_name
      t.string :card_type
      t.string :last_four
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.integer :user_id

      t.timestamps
    end
  end
end

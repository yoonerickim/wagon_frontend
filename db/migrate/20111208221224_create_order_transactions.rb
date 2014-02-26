class CreateOrderTransactions < ActiveRecord::Migration
  def change
    create_table :order_transactions do |t|
      t.integer :amount
      t.boolean :success
      t.string :reference
      t.string :action
      t.string :message
      t.string :authorization
      t.text :params
      t.boolean :test, default: false
      t.string :state
      t.integer :order_id
      t.integer :saved_card_id

      t.timestamps
    end
  end
end

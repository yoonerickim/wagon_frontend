class CreateOrderNotes < ActiveRecord::Migration
  def change
    create_table :order_notes do |t|
      t.text :message
      t.integer :order_id
      t.integer :parent_id

      t.timestamps
    end
  end
end

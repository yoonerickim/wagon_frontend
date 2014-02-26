class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.text :body

      t.timestamps
    end
    add_index(:order_items, :order_id)
  end
end

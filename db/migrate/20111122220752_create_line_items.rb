class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :quantity
      t.integer :menu_item_id
      t.integer :menu_size_id
      t.text :special_instructions

      t.timestamps
    end
  end
end

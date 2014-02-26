class CreateLineItemOptions < ActiveRecord::Migration
  def change
    create_table :line_item_options do |t|
      t.integer :line_item_id
      t.integer :menu_option_item_id
      t.integer :quantity

      t.timestamps
    end
  end
end

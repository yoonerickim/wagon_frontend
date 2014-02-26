class CreateMenuSizes < ActiveRecord::Migration
  def change
    create_table :menu_sizes do |t|
      t.string :name
      t.text :description
      t.integer :price
      t.integer :calories
      t.integer :menu_item_id

      t.timestamps
    end
  end
end

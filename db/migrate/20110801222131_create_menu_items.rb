class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string :name
      t.text :description
      t.string :uid
      t.integer :price

      t.integer :menu_group_id

      t.timestamps
    end
  end
end

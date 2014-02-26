class CreateMenuGroups < ActiveRecord::Migration
  def change
    create_table :menu_groups do |t|
      t.string :name
      t.text :description
      t.string :uid
      t.integer :menu_id

      t.timestamps
    end
  end
end

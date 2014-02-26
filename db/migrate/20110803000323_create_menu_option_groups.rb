class CreateMenuOptionGroups < ActiveRecord::Migration
  def change
    create_table :menu_option_groups do |t|
      t.string :name
      t.text :description
      t.string :optionable_type
      t.integer :optionable_id

      t.timestamps
    end
  end
end

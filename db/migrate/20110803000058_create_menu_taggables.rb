class CreateMenuTaggables < ActiveRecord::Migration
  def change
    create_table :menu_taggables do |t|
      t.integer :menu_item_id
      t.integer :menu_tag_id

      t.timestamps
    end
  end
end

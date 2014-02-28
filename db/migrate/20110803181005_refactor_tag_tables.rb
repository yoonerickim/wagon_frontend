class RefactorTagTables < ActiveRecord::Migration
  def up
    drop_table :locations_tags
    drop_table :menu_tags
    drop_table :menu_taggables
  end

  def down
    create_table "locations_tags", :id => false, :force => true do |t|
      t.integer "location_id"
      t.integer "tag_id"
    end

    create_table "menu_tags", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "menu_taggables", :force => true do |t|
      t.integer  "menu_item_id"
      t.integer  "menu_tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

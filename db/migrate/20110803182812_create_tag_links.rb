class CreateTagLinks < ActiveRecord::Migration
  def change
    create_table :tag_links do |t|
      t.string :tag_id
      t.string :taggable_type
      t.integer :taggable_id

      t.timestamps
    end
  end
end

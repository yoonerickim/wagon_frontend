class RefactorTagsNonPolymorphic < ActiveRecord::Migration
  def up
    # Location Tags
    add_column :tag_links, :location_id, :integer

    # MenuItem Tags
    create_table :item_tags do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :item_tag_links do |t|
      t.integer :menu_item_id
      t.integer :item_tag_id
      t.timestamps
    end

    # Transfer data
    TagLink.all.each do |tl|
      if tl.taggable_type == 'Location'
        tl.location_id = tl.taggable_id
        tl.save
      elsif tl.taggable_type == "MenuItem"
        itl = ItemTagLink.new
        itl.menu_item_id = tl.taggable_id
        itl.item_tag_id = tl.tag_id
        itl.save
        tl.destroy
      end
    end
    remove_column :tag_links, :taggable_type
    remove_column :tag_links, :taggable_id
 end

  def down
    add_column :tag_links, :taggable_id, :integer
    add_column :tag_links, :taggable_type, :string

    TagLink.all.each do |tl|
      tl.taggable_id = tl.location_id
      tl.taggable_type = 'Location'
      tl.save
    end

    ItemTagLink.all.each do |itl|
      tl = TagLink.new
      tl.taggable_id = itl.menu_item_id
      tl.taggable_type = 'MenuItem'
      
      it = ItemTag.find(itl.menu_item_id)
      t = Tag.new
      t.name = it.name
      t.save

      tl.tag_id = t.id

      tl.save
      itl.destroy
    end

    ItemTag.all.each do |it|
      t = Tag.new
      t.name = it.name
      t.save
    end

    drop_table :item_tag_links
    drop_table :item_tags

    remove_column :tag_links, :location_id
  end
end

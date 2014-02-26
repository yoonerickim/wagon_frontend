class AddImagesToMenuItems < ActiveRecord::Migration
  def change
    add_column :menu_items, :image_uid, :string
    add_column :menu_items, :image_name, :string
  end
end

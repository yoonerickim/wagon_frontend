class AddCacheFieldsToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :name, :string
    add_column :line_items, :price, :integer
    add_column :line_items, :size_name, :string
  end
end

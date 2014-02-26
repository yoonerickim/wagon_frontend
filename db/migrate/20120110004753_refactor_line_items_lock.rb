class RefactorLineItemsLock < ActiveRecord::Migration
  def up
    remove_column :orders, :line_items_locked
    add_column :line_items, :locked, :boolean, default: false
    add_column :line_item_options, :locked, :boolean, default: false
  end

  def down
    remove_column :line_item_options, :locked
    remove_column :line_items, :locked
    add_column :orders, :line_items_locked, :boolean, default: false
  end
end

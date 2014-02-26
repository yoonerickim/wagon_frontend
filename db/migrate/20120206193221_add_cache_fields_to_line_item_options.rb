class AddCacheFieldsToLineItemOptions < ActiveRecord::Migration
  def change
    add_column :line_item_options, :option_name, :string
    add_column :line_item_options, :name, :string
    add_column :line_item_options, :additional_cost, :integer
  end
end

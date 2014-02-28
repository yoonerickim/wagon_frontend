class AddStandardToTag < ActiveRecord::Migration
  def change
    add_column :tags, :standard, :boolean
  end
end

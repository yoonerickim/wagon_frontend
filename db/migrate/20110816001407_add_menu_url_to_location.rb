class AddMenuUrlToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :menu_url, :string
  end
end

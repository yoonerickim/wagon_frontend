class ChangeLocationsAndMenusToOneMany < ActiveRecord::Migration
  def up
    add_column :menus, :location_id, :integer
    Menu.find_each do |menu|
      location = menu.locations.first
      menu.update_attributes(location_id: location.id)
    end
    drop_table :menu_links
  end

  def down
    create_table :menu_links do |t|
      t.integer :location_id
      # t.integer :vendor_id # future option if all locations share one menu
      t.integer :menu_id

      t.timestamps
    end

    Menu.find_each do |menu|
      MenuLink.create(location_id: menu.location_id, menu_id: menu.id)
    end
    remove_column :menus, :location_id
  end
end

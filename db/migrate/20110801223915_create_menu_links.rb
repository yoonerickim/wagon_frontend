class CreateMenuLinks < ActiveRecord::Migration
  def change
    create_table :menu_links do |t|
      t.integer :location_id
      # t.integer :vendor_id # future option if all locations share one menu
      t.integer :menu_id

      t.timestamps
    end
  end
end

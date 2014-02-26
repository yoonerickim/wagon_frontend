class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :name
      t.text :description
      t.time :start
      t.time :end
      t.string :uid

      t.timestamps
    end
  end
end

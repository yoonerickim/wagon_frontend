class CreateMenuOptions < ActiveRecord::Migration
  def change
    create_table :menu_options do |t|
      t.string :name
      t.integer :additional_cost
      t.integer :menu_option_group_id

      t.timestamps
    end
  end
end

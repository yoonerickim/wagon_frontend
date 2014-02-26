class FixMenuGroupAndItemOptions < ActiveRecord::Migration
  def up
    drop_table :menu_option_groups
    drop_table :menu_options

    create_table :menu_options do |t|
      t.integer :optionable_id
      t.string :optionable_type

      t.string :name
      t.string :information
      t.integer :minimum
      t.integer :maximum

      t.timestamps
    end

    create_table :menu_option_items do |t|
      t.integer :menu_option_id

      t.string :name
      t.integer :additional_cost

      t.timestamps
    end
  end

  def down
    drop_table :menu_option_items
    drop_table :menu_options

    create_table :menu_options do |t|
      t.string :name
      t.integer :additional_cost
      t.integer :menu_option_group_id
      t.timestamps
    end
    create_table :menu_option_groups do |t|
      t.string :name
      t.text :description
      t.string :optionable_type
      t.integer :optionable_id
      t.timestamps
    end
  end
end

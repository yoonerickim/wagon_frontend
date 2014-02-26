class RefactorTimeMethodsForTimeSlotsAndMenus < ActiveRecord::Migration
  def up
    rename_column :time_slots, :open, :open_at
    rename_column :time_slots, :close, :close_at
    rename_column :menus, :start, :start_at
    rename_column :menus, :end, :end_at
  end

  def down
    rename_column :menus, :end_at, :end
    rename_column :menus, :start_at, :start
    rename_column :time_slots, :close_at, :close
    rename_column :time_slots, :open_at, :open
  end
end

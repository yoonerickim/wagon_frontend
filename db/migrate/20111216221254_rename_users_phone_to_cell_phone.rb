class RenameUsersPhoneToCellPhone < ActiveRecord::Migration
  def up
    rename_column :users, :phone, :cell_phone
  end

  def down
    rename_column :users, :cell_phone, :phone
  end
end

class CreateSpeedMenuAccounts < ActiveRecord::Migration
  def change
    create_table :speed_menu_accounts do |t|
      t.string :make
      t.string :model
      t.integer :location_id

      t.timestamps
    end
  end
end

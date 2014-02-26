class AddClockedInToUsers < ActiveRecord::Migration
  def change
    add_column :users, :clocked_in, :boolean, default: false
  end
end

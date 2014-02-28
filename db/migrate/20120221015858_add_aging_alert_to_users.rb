class AddAgingAlertToUsers < ActiveRecord::Migration
  def change
    add_column :users, :aging_alert, :boolean, default: false
  end
end

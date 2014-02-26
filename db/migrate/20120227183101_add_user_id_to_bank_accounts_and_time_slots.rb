class AddUserIdToBankAccountsAndTimeSlots < ActiveRecord::Migration
  def change
    add_column(:bank_accounts, :user_id, :integer)
    add_index(:bank_accounts, :user_id)
    
    add_column(:time_slots, :user_id, :integer)
    add_index(:time_slots, :user_id)
    
    add_column(:users, :time_zone, :string, :default => "Pacific Time (US & Canada)")
    add_column(:users, :delivery_boundaries, :text)
  end
end

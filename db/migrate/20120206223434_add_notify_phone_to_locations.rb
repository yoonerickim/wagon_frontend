class AddNotifyPhoneToLocations < ActiveRecord::Migration
  def change
    add_column(:locations, :notify_phone, :string)
  end
end

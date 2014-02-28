class AddNotifyEmailToLocations < ActiveRecord::Migration
  def change
    add_column(:locations, :notify_email, :string)
  end
end

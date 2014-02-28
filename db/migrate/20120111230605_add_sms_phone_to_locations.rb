class AddSmsPhoneToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :sms_phone, :string
  end
end

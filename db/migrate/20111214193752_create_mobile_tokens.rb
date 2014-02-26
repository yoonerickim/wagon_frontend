class CreateMobileTokens < ActiveRecord::Migration
  def change
    create_table :mobile_tokens do |t|
      t.string :token
      t.datetime :expires_at
      t.string :device_uid
      t.string :version_uid
      t.integer :user_id

      t.timestamps
    end
  end
end

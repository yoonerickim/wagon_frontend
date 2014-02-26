class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :user_id
      t.integer :vendor_id

      t.integer :roles_mask,        :default => 0

      t.timestamps
    end
  end
end

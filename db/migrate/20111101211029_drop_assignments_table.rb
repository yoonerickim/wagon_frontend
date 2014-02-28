class DropAssignmentsTable < ActiveRecord::Migration
  def up
    drop_table "assignments"
  end

  def down
    create_table "assignments", :force => true do |t|
      t.integer  "user_id"
      t.integer  "vendor_id"
      t.integer  "roles_mask", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
    end
  end
end

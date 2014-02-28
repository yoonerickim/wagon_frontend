class CreateRolesTable < ActiveRecord::Migration
  
  def up
    create_table "roletypes", :force => true do |t|
      t.string "name"
    end
    create_table "roles", :force => true do |t|
      t.boolean  "active"
      t.integer  "roletype_id"
      t.integer  "vendor_id"
      t.integer  "location_id"
      t.integer  "user_id"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "roles", ['active', 'roletype_id', 'vendor_id', 'user_id'], :name => 'a_r_v_u_on_r'
    add_index "roles", ['active', 'roletype_id', 'location_id', 'user_id'], :name => 'a_r_l_u_on_r'
    add_index "roles", ['active', 'roletype_id', 'user_id'], :name => 'a_r_u_on_r'
    
  end

  def down
    drop_table :roles
    drop_table :roletypes
  end
end

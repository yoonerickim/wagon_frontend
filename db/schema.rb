# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121102221752) do

  create_table "activities", :force => true do |t|
    t.integer  "activity_type"
    t.integer  "user_id"
    t.decimal  "lat",           :precision => 15, :scale => 12
    t.decimal  "lng",           :precision => 15, :scale => 12
    t.text     "body"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "addresses", :force => true do |t|
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.float    "lat"
    t.float    "lng"
    t.string   "nickname"
  end

  add_index "addresses", ["lat", "lng"], :name => "index_addresses_on_lat_and_lng"

  create_table "apn_apps", :force => true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "apn_device_groupings", :force => true do |t|
    t.integer "group_id"
    t.integer "device_id"
  end

  add_index "apn_device_groupings", ["device_id"], :name => "index_apn_device_groupings_on_device_id"
  add_index "apn_device_groupings", ["group_id", "device_id"], :name => "index_apn_device_groupings_on_group_id_and_device_id"
  add_index "apn_device_groupings", ["group_id"], :name => "index_apn_device_groupings_on_group_id"

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

  create_table "apn_group_notifications", :force => true do |t|
    t.integer  "group_id",          :null => false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "apn_group_notifications", ["group_id"], :name => "index_apn_group_notifications_on_group_id"

  create_table "apn_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "app_id"
  end

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "apn_pull_notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "launch_notification"
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "institution"
    t.string   "last_four"
    t.integer  "location_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "usa_epay_payment_method_id"
    t.string   "account_type"
    t.integer  "user_id"
  end

  add_index "bank_accounts", ["user_id"], :name => "index_bank_accounts_on_user_id"

  create_table "billing_activities", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.text     "description"
    t.integer  "amount"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "billing_methods", :force => true do |t|
    t.string   "masked_number"
    t.date     "card_expiration"
    t.string   "card_type"
    t.string   "account_holder"
    t.integer  "location_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "custom_locations", :force => true do |t|
    t.string   "name"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "reverse_address"
  end

  create_table "delivery_spots", :force => true do |t|
    t.float    "lat"
    t.float    "lng"
    t.string   "reverse_address"
    t.boolean  "use_reverse",     :default => true
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "order_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "documents", :force => true do |t|
    t.text     "description"
    t.string   "file_uid"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "gvendors", :force => true do |t|
    t.string   "name"
    t.string   "gid"
    t.string   "menu_url"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "gvendors", ["gid"], :name => "index_gvendors_on_gid"
  add_index "gvendors", ["lat", "lng"], :name => "index_gvendors_on_lat_and_lng"

  create_table "item_tag_links", :force => true do |t|
    t.integer  "menu_item_id"
    t.integer  "item_tag_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "item_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "line_item_options", :force => true do |t|
    t.integer  "line_item_id"
    t.integer  "menu_option_item_id"
    t.integer  "quantity"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "locked",              :default => false
    t.string   "option_name"
    t.string   "name"
    t.integer  "additional_cost"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "quantity"
    t.integer  "menu_item_id"
    t.integer  "menu_size_id"
    t.text     "special_instructions"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "locked",               :default => false
    t.string   "name"
    t.integer  "price"
    t.string   "size_name"
  end

  create_table "links", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "linkable_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "linkable_type"
  end

  create_table "locations", :force => true do |t|
    t.integer  "vendor_id"
    t.string   "description"
    t.string   "phone"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "dine_in"
    t.boolean  "take_out"
    t.boolean  "address_delivery"
    t.boolean  "spot_delivery"
    t.string   "openmenu_url"
    t.boolean  "use_openmenu_hours"
    t.string   "menu_url"
    t.boolean  "use_hours_for_delivery_hours"
    t.boolean  "integrate_pos"
    t.float    "delivery_radius"
    t.text     "delivery_boundaries"
    t.integer  "subtledata_location_id"
    t.float    "tax_rate",                     :default => 0.095
    t.string   "sms_phone"
    t.string   "time_zone",                    :default => "Pacific Time (US & Canada)"
    t.string   "fax_number"
    t.integer  "delivery_minimum",             :default => 500
    t.integer  "delivery_fee",                 :default => 0
    t.string   "notify_phone"
    t.string   "notify_email"
    t.integer  "usa_epay_customer_id"
    t.boolean  "contractor_delivery",          :default => true
    t.boolean  "active",                       :default => false
  end

  create_table "menu_groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uid"
    t.integer  "menu_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uid"
    t.integer  "price"
    t.integer  "menu_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "image_uid"
    t.string   "image_name"
  end

  create_table "menu_option_items", :force => true do |t|
    t.integer  "menu_option_id"
    t.string   "name"
    t.integer  "additional_cost"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "menu_options", :force => true do |t|
    t.integer  "optionable_id"
    t.string   "optionable_type"
    t.string   "name"
    t.string   "information"
    t.integer  "minimum"
    t.integer  "maximum"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "menu_sizes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "price"
    t.integer  "calories"
    t.integer  "menu_item_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "menus", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.time     "start_at"
    t.time     "end_at"
    t.string   "uid"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  create_table "mobile_tokens", :force => true do |t|
    t.string   "token"
    t.datetime "expires_at"
    t.string   "device_uid"
    t.string   "version_uid"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "order_items", ["order_id"], :name => "index_order_items_on_order_id"

  create_table "order_notes", :force => true do |t|
    t.text     "message"
    t.integer  "order_id"
    t.integer  "parent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "author_id"
  end

  create_table "order_transactions", :force => true do |t|
    t.integer  "amount"
    t.boolean  "success"
    t.string   "reference"
    t.string   "action"
    t.text     "message"
    t.string   "authorization"
    t.text     "params"
    t.boolean  "test",          :default => false
    t.string   "state"
    t.integer  "order_id"
    t.integer  "saved_card_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "tip",                        :default => 15
    t.boolean  "terms",                      :default => false
    t.float    "tax_rate",                   :default => 0.0
    t.string   "state"
    t.string   "pay_state"
    t.integer  "saved_card_id"
    t.datetime "submitted_at"
    t.datetime "confirmed_at"
    t.datetime "fulfilled_at"
    t.string   "order_type"
    t.integer  "assigned_to_id"
    t.datetime "canceled_at"
    t.datetime "on_delivery_at"
    t.datetime "undeliverable_at"
    t.datetime "completed_at"
    t.boolean  "locked",                     :default => false
    t.text     "delivery_instructions"
    t.text     "confirm_notes"
    t.boolean  "contractor_delivery",        :default => false
    t.integer  "contractor_id"
    t.string   "location_name"
    t.integer  "approx_cost"
    t.integer  "actual_cost"
    t.integer  "custom_location_id"
    t.text     "custom_order_body"
    t.string   "receipt_image_uid"
    t.string   "receipt_image_name"
    t.string   "location_name_original"
    t.text     "custom_order_body_original"
    t.boolean  "use_customer_geometry",      :default => false
  end

  add_index "orders", ["location_id"], :name => "index_orders_on_location_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

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

  add_index "roles", ["active", "roletype_id", "location_id", "user_id"], :name => "a_r_l_u_on_r"
  add_index "roles", ["active", "roletype_id", "user_id"], :name => "a_r_u_on_r"
  add_index "roles", ["active", "roletype_id", "vendor_id", "user_id"], :name => "a_r_v_u_on_r"

  create_table "saved_cards", :force => true do |t|
    t.string   "card_hash"
    t.integer  "usa_epay_payment_method_id"
    t.date     "expires_on"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "card_type"
    t.string   "last_four"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "speed_menu_accounts", :force => true do |t|
    t.string   "make"
    t.string   "model"
    t.integer  "location_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tag_links", :force => true do |t|
    t.integer  "tag_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "standard"
  end

  create_table "time_slots", :force => true do |t|
    t.string   "day"
    t.boolean  "closed"
    t.time     "open_at"
    t.time     "close_at"
    t.integer  "location_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "delivery",    :default => false
    t.integer  "user_id"
  end

  add_index "time_slots", ["user_id"], :name => "index_time_slots_on_user_id"

  create_table "user_geometries", :force => true do |t|
    t.float    "lat"
    t.float    "lng"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "cell_phone"
    t.string   "password_digest"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_phone"
    t.boolean  "vendor_terms",           :default => false
    t.boolean  "administrator"
    t.integer  "usa_epay_customer_id"
    t.boolean  "aging_alert",            :default => false
    t.string   "time_zone",              :default => "Pacific Time (US & Canada)"
    t.text     "delivery_boundaries"
    t.boolean  "clocked_in",             :default => false
    t.float    "lat"
    t.float    "lng"
    t.string   "cohort_id"
  end

  add_index "users", ["cell_phone"], :name => "index_users_on_phone", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["password_reset_token"], :name => "index_users_on_password_reset_token", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "phone"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "registration_token"
    t.string   "legal_name"
    t.text     "description"
    t.string   "logo_image_uid"
    t.string   "logo_image_name"
  end

  add_index "vendors", ["registration_token"], :name => "index_vendors_on_registration_token", :unique => true

end

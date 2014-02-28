# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#### Tags
['American (Traditional)', 'Breakfast & Brunch', 'Burgers', 'Cafe', 
  'Chinese', 'Deli', 'Diner', 'Fast Food', 'Gastropub', 'Gluten-Free', 
  'Indian', 'Italian', 'Mexican', 'Pizza', 'Sandwiches', 'Soup', 
  'Steakhouse', 'Sushi Bar', 'Thai', 'Vegan', 'Vegetarian', 'Teriyaki'
].each do |name|
  Tag.find_or_create_by_name(name, :standard => true)
end

['Afghan', 'African', 'Argentine', 'Asian Fusion', 'Barbeque', 'Basque', 'Belgian', 
  'Brasserie', 'Brazilian', 'British', 'Buffets', 'Burmese', 'Cajun/Creole', 'Cambodian', 
  'Caribbean', 'Creperie', 'Cuban', 'Ethiopian', 'Filipino', 'Fish & Chips', 'Fondue', 
  'Food Stand', 'French', 'German', 'Greek', 'Halal', 'Hawaiian', 'Himalayan/Nepalese', 
  'Hot Dogs', 'Hungarian', 'Indonesian', 'Irish', 'Japanese', 'Korean', 'Kosher', 
  'Latin American', 'Live/Raw Food', 'Malaysian', 'Mediterranean', 'Middle Eastern', 
  'Modern European', 'Moroccan', 'Pakistani', 'Persian/Iranian', 'Peruvian', 'Polish', 
  'Portuguese', 'Russian', 'Scandinavian', 'Seafood', 'Singaporean', 'Soul Food', 
  'Spanish', 'Taiwanese', 'Tapas Bar', 'Tapas/Small Plates', 'Tex-Mex', 'Turkish', 
  'Vietnamese'
].each do |name|
  Tag.find_or_create_by_name(name)
end

if Rails.env.development?
  vendor = Vendor.find_or_initialize_by_name("Bob's Diner")
  vendor.update_attributes(
    "website"=>nil, 
    "phone"=>nil, 
    "registration_token"=>nil, 
    "legal_name"=>"Dinner Corp.", 
    "description"=>"We make great dinner food!"
  )

  location = vendor.locations.find_or_initialize_by_description("Main location")
  location.update_attributes(
    "phone"=>"1231234567",
    "dine_in"=>true, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>true, 
    "openmenu_url"=>"", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>true, 
    "subtledata_location_id"=>4,
    "tax_rate" => 0.071,
    "delivery_boundaries_json"=>"[[30.289249545361447, -97.72801491552735], [30.21392087627404, -97.75891396337892], [30.207096925212184, -97.68544289404298], [30.22549084209524, -97.68544289404298], [30.22489754362061, -97.67788979345704], [30.247143786491762, -97.6868161850586], [30.289249545361447, -97.66656014257813]]"
  )
  address = location.address || Address.new
  address.update_attributes(
    :nickname => "Original Primary Diner",
    :street1 => '4600 E Cesar Chavez St.', 
    :city => 'Austin', 
    :state => 'TX', 
    :zip => 78702, 
    :lat => 30.251889, 
    :lng => -97.703639
  )
  location.address = address

  # lunch menu
  lunch_menu = location.menus.find_or_initialize_by_name("Lunch")
  lunch_menu.update_attributes(
    :description => "Great lunches.",
    :start_at => Time.now.utc.change(hour: 11, minute: 0, sec: 0, usec: 0),
    :end_at => Time.now.utc.change(hour: 16, minute: 0, sec: 0, usec: 0)
  )

  lunch_starters = lunch_menu.groups.find_or_initialize_by_name("Starters")
  lunch_starters.update_attributes(
    :description => "Something simple to start."
  )
  house_salad = lunch_starters.items.find_or_initialize_by_name("Ceasar Salad")
  house_salad.update_attributes(
    :description => "Our first starter. Comes with lemon.",
    :price => 599
  )

  lunch_sandwiches = lunch_menu.groups.find_or_initialize_by_name("Sandwiches")
  lunch_sandwiches.update_attributes(
    :description => "Something tasty for lunch"
  )
  club_sandwich = lunch_sandwiches.items.find_or_initialize_by_name("Club Sandwich")
  club_sandwich.update_attributes(
    :description => "Turkey, Bacon, Cheese, Avocado, Ham.",
    :price => 899
  )
  bread_options = lunch_sandwiches.options.find_or_initialize_by_name("Type of Bread")
  bread_options.update_attributes(
    :minimum => 1,
    :maximum => 1,
    :information => "Wholesome bread."
  )
  white_bread = bread_options.option_items.find_or_initialize_by_name("White")
  white_bread.update_attributes(
    :additional_cost => 0
  )
  croissant = bread_options.option_items.find_or_initialize_by_name("Croissant")
  croissant.update_attributes(
    :additional_cost => 200
  )

  # dinner menu
  dinner_menu = location.menus.find_or_initialize_by_name("Dinner")
  dinner_menu.update_attributes(
    :description => "Great dinners.",
    :start_at => Time.now.utc.change(hour: 16, minute: 0, sec: 0, usec: 0),
    :end_at => Time.now.utc.change(hour: 22, minute: 0, sec: 0, usec: 0)
  )

  appetizers = dinner_menu.groups.find_or_initialize_by_name("Appetizers")
  appetizers.update_attributes(
    :description => "Calorie heavy food."
  )
  cheese_sticks = appetizers.items.find_or_initialize_by_name("Cheese Sticks")
  cheese_sticks.update_attributes(
    :description => "Mozzerella cheese sticks with sauce.",
    :price => nil
  )
  regular = cheese_sticks.sizes.find_or_initialize_by_name("Regular")
  regular.update_attributes(
    :description => nil,
    :price => 799
  )
  large = cheese_sticks.sizes.find_or_initialize_by_name("Large")
  large.update_attributes(
    :description => "Extra big and fried.",
    :price => 1199
  )


  entrees = dinner_menu.groups.find_or_initialize_by_name("Entrees")
  entrees.update_attributes(
    :description => "Main Course"
  )
  salad = entrees.items.find_or_initialize_by_name("Dinner Salad")
  salad.update_attributes(
    :description => "Salad with your choice of meat and dressing.",
    :price => 1099
  )
  salad_meats = salad.options.find_or_initialize_by_name("Meats")
  salad_meats.update_attributes(
    :information => "Make your salad filling"
  )
  chicken = salad_meats.option_items.find_or_initialize_by_name("Chicken")
  chicken.update_attributes(
    :additional_cost => 199
  )
  tofu = salad_meats.option_items.find_or_initialize_by_name("Tofu")
  tofu.update_attributes(
    :additional_cost => 399
  )
  salad_dressings = salad.options.find_or_initialize_by_name("Dressings")
  salad_dressings.update_attributes(
    :maximum => 2,
    :information => "Tasty"
  )
  ranch = salad_dressings.option_items.find_or_initialize_by_name("Ranch")
  ranch.update_attributes(
    :additional_cost => 0
  )
  blue_cheese = salad_dressings.option_items.find_or_initialize_by_name("Blue Cheese")
  blue_cheese.update_attributes(
    :additional_cost => nil
  )

  # dessert menu
  dessert_menu = location.menus.find_or_initialize_by_name("Dessert")
  dessert_menu.update_attributes(
    :description => "Great desserts.",
    :start_at => Time.now.utc.change(hour: 8, minute: 0, sec: 0, usec: 0),
    :end_at => Time.now.utc.change(hour: 22, minute: 0, sec: 0, usec: 0)
  )

  cakes = dessert_menu.groups.find_or_initialize_by_name("cakes")
  cakes.update_attributes(
    :description => "Delectable!"
  )
  cheese_cake = cakes.items.find_or_initialize_by_name("Cheese Cake")
  cheese_cake.update_attributes(
    :description => "So good!",
    :price => 799
  )
  fudge_cake = cakes.items.find_or_initialize_by_name("Fudge Brownie Cake")
  fudge_cake.update_attributes(
    :description => "More chocolate than you can handle!",
    :price => 699
  )

  ## 1 - super user
  super_user = User.find_or_initialize_by_email('super@hitthespot.com')
  super_user.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  super_user.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Clark", 
    "last_name"=>"Kent",
    "cell_phone"=>"1231231111"
  )
  super_user_role = super_user.roles.find_or_create_by_title("SuperUser")
  super_user_role.update_attributes(:roletype_id => Role::SUPER_USER, :active => true)

  ## 2 - vendor exec
  vendor_exec = User.find_or_initialize_by_email('vendor-exec@diner.com')
  vendor_exec.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  vendor_exec.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Fred", 
    "last_name"=>"Flintstone",
    "cell_phone"=>"1231232222"
  )
  vendor_exec_role = vendor.roles.find_or_initialize_by_title('VendorExec')
  vendor_exec_role.update_attributes(:roletype_id => Role::VENDOR_EXEC, :user_id => vendor_exec.id, :active => true)

  ## 3 - vendor admin
  vendor_admin = User.find_or_initialize_by_email('vendor-admin@diner.com')
  vendor_admin.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  vendor_admin.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Wilma", 
    "last_name"=>"Flintstone",
    "cell_phone"=>"1231233333"
  )
  vendor_admin_role = vendor.roles.find_or_initialize_by_title('VendorAdmin')
  vendor_admin_role.update_attributes(:roletype_id => Role::VENDOR_ADMIN, :user_id => vendor_admin.id, :active => true)

  ## 4 - location exec
  location_exec = User.find_or_initialize_by_email('location-exec@diner.com')
  location_exec.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  location_exec.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Barney", 
    "last_name"=>"Rubble",
    "cell_phone"=>"1231234444"
  )
  location_exec_role = location.roles.find_or_initialize_by_title('LocationExec')
  location_exec_role.update_attributes(:roletype_id => Role::LOCATION_EXEC, :user_id => location_exec.id, :active => true)

  # 5 - location admin 
  location_admin = User.find_or_initialize_by_email('location-admin@diner.com')
  location_admin.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  location_admin.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Betty", 
    "last_name"=>"Rubble",
    "cell_phone"=>"1231235555"
  )
  location_admin_role = location.roles.find_or_initialize_by_title('LocationAdmin')
  location_admin_role.update_attributes(:roletype_id => Role::LOCATION_ADMIN, :user_id => location_admin.id, :active => true)

  # 6 - location delivery staff 
  location_deliverer = User.find_or_initialize_by_email('location-deliverer@diner.com')
  location_deliverer.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  location_deliverer.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Bamm-Bamm", 
    "last_name"=>"Rubble",
    "cell_phone"=>"1231236666"
  )
  location_deliverer_role = location.roles.find_or_initialize_by_title('LocationDeliverer')
  location_deliverer_role.update_attributes(:roletype_id => Role::LOCATION_DELIVERY_STAFF, :user_id => location_deliverer.id, :active => true)

  # 7 - location server staff
  location_server = User.find_or_initialize_by_email('location-server@diner.com')
  location_server.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  location_server.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Pebbles", 
    "last_name"=>"Rubble",
    "cell_phone"=>"1231237777"
  )
  location_server_role = location.roles.find_or_initialize_by_title('LocationServer')
  location_server_role.update_attributes(:roletype_id => Role::LOCATION_SERVER_STAFF, :user_id => location_server.id, :active => true)

  # Contractor
  contractor = User.find_or_initialize_by_email('joe@deliver.com')
  contractor.update_attributes(
    "password" => 'password',
    "vendor_terms"=> false,
    "first_name"=>"Joe",
    "last_name"=>"Deliver",
    "cell_phone"=>"1231238888",
    "clocked_in"=> true,
    "delivery_boundaries_json"=>"[[30.265848988219453, -97.74755183593749], [30.2640698129178, -97.68438044921874], [30.176850753403958, -97.68438044921874], [30.08004812468937, -97.73793879882811], [30.10618824682117, -97.82720271484374]]"
  )
  contractor_role = contractor.roles.find_or_initialize_by_title('Contractor')
  contractor_role.update_attributes(
    :roletype_id => Role::DELIVERY_CONTRACTOR,
    :active => true
  )


  #### Test vendors and locations

  # Incomplete Menu
  northlake_tavern = Vendor.find_or_initialize_by_name("Northlake Tavern & Pizza House")
  northlake_tavern.update_attributes(
    "website"=>"http://www.northlaketavern.com", 
    "phone"=>"206-633-5317", 
    "registration_token"=>nil, 
    "legal_name"=>"Northlake Tavern & Pizza House", 
    "description"=>"Tavern and Pizza!"
  )
  location = northlake_tavern.locations.find_or_initialize_by_description("Northlake")
  location.update_attributes(
    "phone"=>"206-633-5317",
    "dine_in"=>true, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>true, 
    "openmenu_url"=>"http://openmenu.com/menu/20e454b2-15bb-11e0-b40e-0018512e6b26", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>false, 
    "delivery_boundaries_json"=> "[[47.6867674553722, -122.33917878320312], [47.67659722146471, -122.34947846582031], [47.65416947493975, -122.34570191552734], [47.64514941740708, -122.33540223291016], [47.65347567966783, -122.32475922753906], [47.652781875178086, -122.31480286767578], [47.64838756601614, -122.30965302636719], [47.64838756601614, -122.30038331201172], [47.65393821087331, -122.29832337548828], [47.65648205927302, -122.28905366113281], [47.66781224204651, -122.2887103383789], [47.68306941789724, -122.29008362939453], [47.68283828185018, -122.3158328359375]]", 
    "subtledata_location_id"=>nil,
    "tax_rate" => 0.095
  )
  address = location.address || Address.new
  address.update_attributes(
    :nickname => 'Northlake',
    :street1 => '660 Northlake Way NE', 
    :city => 'Seattle', 
    :state => 'WA', 
    :zip => 98105, 
    :lat => 47.654632, 
    :lng => -122.321326
  )
  location.address = address
  location.save


  # Spitfire
  spitfire = Vendor.find_or_initialize_by_name("Spitfire")
  spitfire.update_attributes(
    "website"=>"http://www.spitfireseattle.com", 
    "phone"=>"206-441-7966", 
    "registration_token"=>nil, 
    "legal_name"=>"Spitfire", 
    "description"=>"Food and meeting place."
  )
  location = spitfire.locations.find_or_initialize_by_description("Fourth")
  location.update_attributes(
    "phone"=>"206-441-7966",
    "dine_in"=>false, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>false, 
    "openmenu_url"=>"http://openmenu.com/menu/20e46a60-15bb-11e0-b40e-0018512e6b26", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>false, 
    "delivery_boundaries_json"=>"[[47.667511238561616, -122.40825200048829], [47.65248078502346, -122.4195816513672], [47.63698332694007, -122.4085953232422], [47.63189360662144, -122.39280247656251], [47.63189360662144, -122.3866226669922], [47.62379530257724, -122.36945652929688], [47.61847287671148, -122.35881352392579], [47.61199267037867, -122.35126042333985], [47.609678116350025, -122.34199070898438], [47.6166214711342, -122.33134770361329], [47.62495227997695, -122.32894444433595], [47.62842305853158, -122.33890080419923], [47.64184123388177, -122.3426773544922], [47.65201824090908, -122.36224675146485]]", 
    "subtledata_location_id"=>nil,
    "tax_rate" => 0.095
  )
  address = location.address || Address.new
  address.update_attributes(
    :nickname => 'Fourth',
    :street1 => '2219 Fourth Ave.', 
    :city => 'Seattle', 
    :state => 'WA', 
    :zip => 98121, 
    :lat => 47.61477, 
    :lng => -122.343364
  )
  location.address = address
  location.save

  ## 2 - vendor exec
  vendor_exec = User.find_or_initialize_by_email('vendor-exec@spitfire.com')
  vendor_exec.password_digest = "$2a$10$TKXmFKu8yxTGrmm1G752UefShZ5lrVh.RzIvek11lcapyQyfXnKq." # 'password'
  vendor_exec.update_attributes(
    "vendor_terms" => true,
    "first_name"=>"Fred", 
    "last_name"=>"Spits",
    "cell_phone"=>"1231232223"
  )
  vendor_exec_role = spitfire.roles.find_or_initialize_by_title('VendorExec')
  vendor_exec_role.update_attributes(:roletype_id => Role::VENDOR_EXEC, :user_id => vendor_exec.id, :active => true)

  # Shultzy's
  shultzys = Vendor.find_or_initialize_by_name("Shultzy's")
  shultzys.update_attributes(
    "website"=>"http://www.shultzys.com", 
    "phone"=>"206-548-9461", 
    "registration_token"=>nil, 
    "legal_name"=>"Shultzy's", 
    "description"=>"Burgers."
  )
  location = shultzys.locations.find_or_initialize_by_description("University")
  location.update_attributes(
    "phone"=>"206-548-9461",
    "dine_in"=>true, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>true, 
    "openmenu_url"=>"http://openmenu.com/menu/20ee8068-15bb-11e0-b40e-0018512e6b26", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>false, 
    "subtledata_location_id"=>nil,
    "tax_rate" => 0.095
  )
  address = location.address || Address.new
  address.update_attributes(
    :nickname => 'University',
    :street1 => '4114 University Way NE', 
    :city => 'Seattle', 
    :state => 'WA', 
    :zip => 98105, 
    :lat => 47.657355, 
    :lng => -122.313207
  )
  location.address = address
  location.save


  # Outback
  outback = Vendor.find_or_initialize_by_name("Outback Steakhouse")
  outback.update_attributes(
    "website"=>"http://www.outback.com/", 
    "phone"=>"813.282.1225", 
    "registration_token"=>nil, 
    "legal_name"=>"Outback Steakhouse", 
    "description"=>"Every day we start fresh. We chop, slice and stir our way to freshly made soups, sauces, sides and dressings. Since day one we've sought out the best ingredients to create the great tasting, bold, flavors you crave."
  )
  westlake = outback.locations.find_or_initialize_by_description("Westlake")
  westlake.update_attributes(
    "phone"=>"(206) 262-0326",
    "dine_in"=>true, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>true, 
    "openmenu_url"=>"http://openmenu.com/menu/20d6b8ac-15bb-11e0-b40e-0018512e6b26", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>false, 
    "subtledata_location_id"=>nil,
    "tax_rate" => 0.095
  )
  address = westlake.address || Address.new
  address.update_attributes(
    :nickname => 'Westlake',
    :street1 => '701 Westlake Ave. North', 
    :city => 'Seattle', 
    :state => 'WA', 
    :zip => 98109, 
    :lat => 47.625989, 
    :lng => -122.339215
  )
  westlake.address = address
  westlake.save
  westlake.tags << Tag.first

  aurora = outback.locations.find_or_initialize_by_description("Aurora")
  aurora.update_attributes(
    "phone"=>"(206) 367-7780",
    "dine_in"=>true, "take_out"=>true, "address_delivery"=>true, "spot_delivery"=>true, 
    "openmenu_url"=>"http://openmenu.com/menu/20d6a6fa-15bb-11e0-b40e-0018512e6b26", 
    "use_openmenu_hours"=>nil, 
    "menu_url"=>"", 
    "use_hours_for_delivery_hours"=>true, 
    "integrate_pos"=>false, 
    "subtledata_location_id"=>nil,
    "tax_rate" => 0.095
  )
  address = aurora.address || Address.new
  address.update_attributes(
    :nickname => 'Aurora',
    :street1 => '13231 Aurora Ave. N.', 
    :city => 'Seattle', 
    :state => 'WA', 
    :zip => 98133, 
    :lat => 47.725352, 
    :lng => -122.345033
  )
  aurora.address = address
  aurora.save
  aurora.tags << Tag.first

  Location.find_each do |location|
    TimeSlot::DAYS.each do |day|
      location.hours << Hour.create!(
        day: day, closed: false, 
        open_at: Time.new.utc.change(hour: 8, minute: 0, second: 0),
        close_at: Time.new.utc.change(hour: 23, minute: 0, second: 0)
      ) unless location.hours.exists?(day: day)
    end
  end

  User.find_each do |user|
    user.set_geometry(30.268705,-97.679358)
  end

end # if Rails.env.development?

if Rails.env.demo? || Rails.env.staging? || Rails.env.production? 


end

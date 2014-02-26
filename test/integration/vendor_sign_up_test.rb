require 'test_helper'

class VendorSignUpTest < ActionDispatch::IntegrationTest

  #@javascript
  #test "integration vendor signs up successfully" do
  #  skip "need to figure out js"

  #  visit root_path
  #  fill_and_submit_front_page_form

  #  visit registration_vendor_path(Vendor.last.registration_token, :email => User.last.email)
  #  within :css, 'form.edit_vendor' do
  #    fill_in_genaric_location_fields

  #    # open menu
  #    fill_in "OpenMenu URL",           :with => ""
  #    uncheck "Use OpenMenu hours"

  #    fill_in_operational_hours
  #    fill_in_menu

  #    # pos integration
  #    choose 'Integrate with my Point of Sale system.'

  #    fill_in "Make or Manufacturer Name",                :with => "Registers, Inc."
  #    fill_in "Model or Product Line",                    :with => "Cash Cow 1000"

  #    fill_in "Credit Card",                              :with => "1234123412341234"
  #    select "July",                                      :from => "vendor_locations_attributes_0_billing_method_attributes_card_expiration_2i"
  #    select Time.now.next_year.year.to_s,                :from => "vendor_locations_attributes_0_billing_method_attributes_card_expiration_1i"
  #    select "Visa",                                      :from => "Card Type"
  #    fill_in "Security Code",                            :with => "123"
  #    fill_in "Name on Card",                             :with => "Wilma Flintstone"

  #    assert page.has_content? "Next Step"
  #    click_link_or_button "next next1"
  #    fill_in_personal_guarantee

  #    #save_and_open_page

  #    click_button 'Submit for review!'
  #  end

  #  #save_and_open_page

  #  assert has_content?("Thank you! Your application is being reviewed!")

  #  assert_equal "123-123-1234", Vendor.last.locations.first.phone
  #  assert Vendor.last.locations.first.tag_names =~ /burgers/

  #  assert_nil Vendor.last.registration_token

  #  assert User.last.vendor_terms

  #end

  #test "open menu vendor signs up successfully" do
  #  skip "need to figure out js"
  #  visit root_path
  #  fill_and_submit_front_page_form

  #  visit registration_vendor_path(Vendor.last.registration_token, :email => User.last.email)
  #  within :css, 'form.edit_vendor' do
  #    fill_in_genaric_location_fields

  #    fill_in "OpenMenu URL",           :with => "http://openmenu.com/menu/20ee53fe-15bb-11e0-b40e-0018512e6b26"
  #    check "Use OpenMenu hours"

  #    fill_in_menu

  #    # standard integration
  #    choose 'Deposit monies into my account once per week.'
  #    fill_in_bank_fields

  #    fill_in_personal_guarantee

  #    click_button 'Submit for review!'
  #  end
  #  
  #  assert has_content?("Thank you! Your application is being reviewed!")
  #  
  #  assert Location.last.openmenu_url
  #  assert Location.last.use_openmenu_hours
  #end

  #test "open menu vendor with manual hours signs up successfully" do
  #  skip "need to figure out js"
  #  visit root_path
  #  fill_and_submit_front_page_form

  #  visit registration_vendor_path(Vendor.last.registration_token, :email => User.last.email)
  #  within :css, 'form.edit_vendor' do
  #    fill_in_genaric_location_fields

  #    fill_in "OpenMenu URL",           :with => "http://openmenu.com/menu/20ee53fe-15bb-11e0-b40e-0018512e6b26"
  #    uncheck "Use OpenMenu hours"

  #    fill_in_operational_hours
  #    fill_in_menu

  #    # standard integration
  #    choose 'Deposit monies into my account once per week.'
  #    fill_in_bank_fields

  #    fill_in_personal_guarantee

  #    click_button 'Submit for review!'
  #  end

  #  assert has_content?("Thank you! Your application is being reviewed!")

  #  assert Location.last.openmenu_url
  #  assert !Location.last.use_openmenu_hours
  #end

  #test "vendor without openmenu signs up successfully" do
  #  skip "need to figure out js"
  #  visit root_path
  #  fill_and_submit_front_page_form

  #  visit registration_vendor_path(Vendor.last.registration_token, :email => User.last.email)
  #  within :css, 'form.edit_vendor' do
  #    fill_in_genaric_location_fields

  #    fill_in "OpenMenu URL",           :with => ""
  #    uncheck "Use OpenMenu hours"

  #    fill_in_operational_hours
  #    fill_in_menu

  #    # standard integration
  #    choose 'Deposit monies into my account once per week.'
  #    fill_in_bank_fields

  #    # menu builder TODO

  #    fill_in_personal_guarantee

  #    click_button 'Submit for review!'
  #  end

  #  assert has_content?("Thank you! Your application is being reviewed!")

  #  assert Location.last.openmenu_url.blank?
  #  assert !Location.last.use_openmenu_hours
  #end

  private

  def fill_and_submit_front_page_form
    # fill in details
    fill_in 'Vendor',                   :with => "Wilma's Dinner"
    fill_in 'First name',               :with => "Wilma"
    fill_in 'Last name',                :with => "Flintstone"
    fill_in 'Email',                    :with => "wilma@dinner.com"
    click_button 'Go!'
  end

  def fill_in_genaric_location_fields
    # first location (location)
    fill_in 'Description',              :with => "Main Location"

    fill_in 'Street1',                  :with => "123 Bedrock Way"
    fill_in 'Street2',                  :with => "Suite 3"
    fill_in 'City',                     :with => "Bedrock"
    fill_in 'State',                    :with => "Wyoming"
    fill_in 'Zip',                      :with => "12345"

    fill_in 'Tags',                     :with => "burgers drinks happy-hour"

    fill_in 'Phone',                    :with => "123-123-1234"

    select 'Website',                   :from => "vendor_locations_attributes_0_links_attributes_0_name"
    fill_in "vendor_locations_attributes_0_links_attributes_0_value", :with => "http://dinner.com"

    select 'Facebook',                  :from => "vendor_locations_attributes_0_links_attributes_1_name"
    fill_in "vendor_locations_attributes_0_links_attributes_1_value", :with => "http://facebook.com/dinner"

    # fulfullment types
    check 'Dine in'
    check 'Take out'
    check 'Address delivery'
    check 'GPS delivery'
  end

  def fill_in_operational_hours
    # Operational Hours
    select '10',            :from => "vendor_locations_attributes_0_hours_attributes_0_open_4i"
    select '30',            :from => 'vendor_locations_attributes_0_hours_attributes_0_open_5i'
    select '17',            :from => "vendor_locations_attributes_0_hours_attributes_0_close_4i"
    select '30',            :from => 'vendor_locations_attributes_0_hours_attributes_0_close_5i'
    check 'vendor_locations_attributes_0_hours_attributes_1_closed'
    check 'vendor_locations_attributes_0_hours_attributes_2_closed'
    check 'vendor_locations_attributes_0_hours_attributes_3_closed'
    check 'vendor_locations_attributes_0_hours_attributes_4_closed'
    check 'vendor_locations_attributes_0_hours_attributes_5_closed'
    check 'vendor_locations_attributes_0_hours_attributes_6_closed'
  end

  def fill_in_menu
    #fill_in 'vendor_locations_attributes_0_menus_attributes_0_name', :with => "Mine!"
  end

  def fill_in_personal_guarantee
    fill_in "Personal Phone Number",                    :with => "123-123-1234" 
    #check 'I agree to the terms and conditions of this site.'
    check 'vendor_users_attributes_0_vendor_terms'
  end

  def fill_in_bank_fields
    fill_in "Bank Institution",       :with => "Historic Bank"
    fill_in "Account Number",         :with => "123456789012"
    fill_in "Routing Number",         :with => "123456789"
  end
end

require 'test_helper'

class VendorsControllerTest < ActionController::TestCase

  #test "should render vendor sign up form" do
  #  get :new
  #  
  #  assert_select "form[action=#{vendors_path}]" do
  #    assert_select "input[type=text][name='vendor[name]']"
  #    assert_select "input[type=text][name='vendor[assignments_attributes][0][user_attributes][first_name]']"
  #    assert_select "input[type=text][name='vendor[assignments_attributes][0][user_attributes][last_name]']"
  #    assert_select "input[type=text][name='vendor[assignments_attributes][0][user_attributes][email]']"
  #    assert_select "input[type=submit]"
  #  end
  #end


  #test "should create a vendor with user" do
  #  params = {"vendor"=>{"name"=>"Wilma's Dinner", "assignments_attributes"=>{"0"=>{"user_attributes"=>{"first_name"=>"Wilma", "last_name"=>"Flintstone", "email"=>"wilma@flintsones.com"}}}}}
  #  assert_difference "Vendor.count" do
  #    assert_difference "Assignment.count" do
  #      assert_difference "User.count" do
  #        assert_difference "ActionMailer::Base.deliveries.count" do
  #          post :create, params
  #        end
  #      end
  #    end
  #  end

  #  assert_redirected_to root_path
  #  assert_equal "Please check your email to complete your registration.", flash[:notice]
  #end

  #test "should fail to create a vendor" do
  #  params = {"vendor"=>{"name"=>"Wilma's Dinner", "assignments_attributes"=>{"0"=>{"user_attributes"=>{"first_name"=>"Wilma", "last_name"=>"Flintstone"}}}}}
  #  assert_no_difference "Vendor.count" do
  #    assert_no_difference "Assignment.count" do
  #      assert_no_difference "User.count" do
  #        assert_no_difference "ActionMailer::Base.deliveries.count" do
  #          post :create, params
  #        end
  #      end
  #    end
  #  end

  #  assert_template 'new'
  #end

  #test "registration page should have form" do
  #  vendor = Factory.build(:vendor)
  #  assignment = vendor.assignments.build
  #  assignment.user = Factory.build(:user)
  #  vendor.save!

  #  get :registration, :id => vendor.registration_token, :email => assignment.user.email
  #  assert_response :success

  #  #puts response.body

  #  assert_select "form[action=#{register_vendor_path(vendor.registration_token)}]" do
  #    assert_select "input[type=text][name='location[phone]']"
  #    assert_select "input[type=text][name='location[address_attributes][street1]']"
  #    assert_select "input[type=text][name='location[address_attributes][street2]']"
  #    assert_select "input[type=text][name='location[address_attributes][city]']"
  #    assert_select "input[type=text][name='location[address_attributes][state]']"
  #    assert_select "input[type=text][name='location[address_attributes][zip]']"

  #    assert_select "input[type=text][name='location[phone]']"

  #    assert_select "input[type=hidden][name='location[links_attributes][0][name]']"
  #    assert_select "input[type=text][name='location[links_attributes][0][value]']"

  #    # Add tags

  #    assert_select "input[type=hidden][name='location[hours_attributes][0][day]']"
  #    assert_select "input[type=checkbox][name='location[hours_attributes][0][closed]']"

  #    assert_select "input[type=radio][name='location[dine_in]']", 2
  #    assert_select "input[type=radio][name='location[take_out]']", 2
  #    assert_select "input[type=radio][name='location[address_delivery]']", 2
  #    assert_select "input[type=radio][name='location[spot_delivery]']", 2

  #    assert_select "input[type=text][name='location[menu_url]']"
  #    assert_select "input[type=file][name='location[menu_uploads_attributes][0][file]']"
  #    assert_select "input[type=hidden][name='location[menu_uploads_attributes][0][retained_file]']"
  #    assert_select "textarea[name='location[menu_uploads_attributes][0][description]']"
  #    assert_select "input[type=text][name='location[openmenu_url]']"
  #    #assert_select "input[type=checkbox][name='location[use_openmenu_hours]']" # TODO remove from db if not needed

  #    assert_select "input[type=text][name='location[pos_account_attributes][model]']"
  #    assert_select "input[type=text][name='location[pos_account_attributes][make]']"

  #    assert_select "input[type=text][name='location[billing_method_attributes][card_number]']"
  #    assert_select "input[type=text][name='location[billing_method_attributes][security_code]']"
  #    assert_select "select[name='location[billing_method_attributes][card_expiration(2i)]']"
  #    assert_select "select[name='location[billing_method_attributes][card_expiration(1i)]']"
  #    assert_select "input[type=text][name='location[billing_method_attributes][account_holder]']"
  #    assert_select "input[type=text][name='location[bank_account_attributes][institution]']"
  #    assert_select "input[type=text][name='location[bank_account_attributes][account]']"
  #    assert_select "input[type=text][name='location[bank_account_attributes][routing]']"

  #    #assert_select "input[type=text][name='vendor[users_attributes][0][contact_phone]']"
  #    #assert_select "input[type=checkbox][name='vendor[users_attributes][0][vendor_terms]']"

  #    assert_select "input[type=checkbox][name='user[vendor_terms]']"

  #    assert_select "input[type=submit]"
  #  end
  #end

  #test "register first location with pos" do
  #  vendor = Factory.build(:vendor)
  #  user = Factory.build(:user)
  #  assignment = vendor.assignments.build
  #  assignment.user = user
  #  vendor.save!

  #  params = {
  #    "id" => vendor.registration_token, 
  #    "location"=>{
  #      "vendor_attributes" => {
  #        "name" => "Name",
  #        "legal_name" => "Legal Name",
  #        "description" => "Vendor Description",
  #        "id" => vendor.id
  #      },
  #      "description"=>"Description", 
  #      "address_attributes"=>{
  #        "street1"=>"Stree1", 
  #        "street2"=>"Street2", 
  #        "city"=>"City", 
  #        "state"=>"WA", 
  #        "zip"=>"12345"
  #      }, 
  #      "phone"=>"123-1234-1234", 
  #      "links_attributes"=>{
  #        "0"=>{
  #          "name"=>"Website", 
  #          "value"=>"http://zoot.com", 
  #          "_destroy"=>"false"
  #        }, 
  #        "1"=>{
  #          "name"=>"Website", 
  #          "value"=>"http://cook.com", 
  #          "_destroy"=>"false"
  #        }
  #      }, 
  #      "dine_in"=>"1", 
  #      "take_out"=>"1", 
  #      "address_delivery"=>"0", 
  #      "spot_delivery"=>"0", 
  #      "integrate_pos"=>"true", 
  #      "pos_account_attributes"=>{
  #        "make"=>"Make", 
  #        "model"=>"Model"
  #      }, 
  #      "menu_type"=>"web_url", 
  #      "menu_url"=>"http://mymenu.com", 
  #      "menu_uploads_attributes"=>{
  #        "0"=>{
  #          "retained_file"=>"", 
  #          "description"=>"", 
  #          "_destroy"=>"false"
  #        }
  #      }, 
  #      "openmenu_url"=>"", 
  #      "hours_attributes"=>{"0"=>{"day"=>"Sunday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "1"=>{"day"=>"Monday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "2"=>{"day"=>"Tuesday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "3"=>{"day"=>"Wednesday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "4"=>{"day"=>"Thursday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "5"=>{"day"=>"Friday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "6"=>{"day"=>"Saturday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}}, 
  #      "billing_method_attributes"=>{
  #        "card_number"=>"1111222233334444", 
  #        "security_code"=>"123", 
  #        "card_expiration(3i)"=>"1", 
  #        "card_expiration(2i)"=>"10", 
  #        "card_expiration(1i)"=>"2011", 
  #        "card_type"=>"Visa", 
  #        "account_holder"=>"Tu Tu"
  #      }, 
  #      "bank_account_attributes"=>{
  #        "institution"=>"", 
  #        "account"=>"", 
  #        "routing"=>""
  #      } 
  #    },
  #    "user" => {
  #      "id" => user.id,
  #      "first_name" => "Fred",
  #      "last_name" => "Flintstone",
  #      "contact_phone" => "123-123-1234",
  #      "vendor_terms" => "1"
  #    },
  #    "assignment" => {
  #      "title" => "Stone Worker",
  #    }
  #  }
  #  assert_no_difference 'Vendor.count', "Vendor" do
  #    assert_difference 'Location.count', 1, "Location" do
  #     assert_difference 'Link.count', 2, "Link" do
  #      assert_no_difference 'Tag.count', "Tag" do
  #       assert_difference 'TimeSlot.count', 7, "TimeSlots" do
  #        assert_difference 'SpeedMenuAccount.count', 1, "SpeedMenuAccount" do
  #         assert_difference 'BillingMethod.count', 1, "BillingMethod" do
  #          assert_difference 'BankAccount.count', 1, "BankAccount" do
  #            assert_no_difference 'User.count', "User" do
  #              post :register, params
  #            end
  #          end
  #         end
  #        end
  #       end
  #      end
  #     end
  #    end
  #  end

  #  assert_nil Vendor.last.registration_token

  #  assert_equal "Thank you! Your application is being reviewed!", flash[:notice]
  #  assert_redirected_to root_path
  #end

  #test "register first location" do
  #  vendor = Factory.build(:vendor)
  #  user = Factory.build(:user)
  #  2.times { Factory.create(:tag).id }
  #  tag_ids = Tag.all.map {|t| t.id }
  #  assignment = vendor.assignments.build
  #  assignment.user = user
  #  vendor.save!

  #  params = {
  #    "id" => vendor.registration_token, 
  #    "location"=>{
  #      "description"=>"Description", 
  #      "address_attributes"=>{
  #        "street1"=>"Stree1", 
  #        "street2"=>"Street2", 
  #        "city"=>"City", 
  #        "state"=>"WA", 
  #        "zip"=>"12345"
  #      }, 
  #      "phone"=>"123-1234-1234", 
  #      "links_attributes"=>{
  #        "0"=>{
  #          "name"=>"Website", 
  #          "value"=>"http://zoot.com", 
  #          "_destroy"=>"false"
  #        }, 
  #        "1"=>{
  #          "name"=>"Website", 
  #          "value"=>"", 
  #          "_destroy"=>"false"
  #        }
  #      }, 
  #      "tag_ids" => tag_ids,
  #      "dine_in"=>"1", 
  #      "take_out"=>"1", 
  #      "address_delivery"=>"0", 
  #      "spot_delivery"=>"0", 
  #      "integrate_pos"=>"false", 
  #      "pos_account_attributes"=>{
  #        "make"=>"Make for Future", 
  #        "model"=>"Model for Future"
  #      }, 
  #      "menu_type"=>"web_url", 
  #      "menu_url"=>"http://mymenu.com", 
  #      "menu_uploads_attributes"=>{
  #        "0"=>{
  #          "retained_file"=>"", 
  #          "description"=>"", 
  #          "_destroy"=>"false"
  #        }
  #      }, 
  #      "openmenu_url"=>"", 
  #      "hours_attributes"=>{"0"=>{"day"=>"Sunday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "1"=>{"day"=>"Monday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "2"=>{"day"=>"Tuesday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "3"=>{"day"=>"Wednesday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "4"=>{"day"=>"Thursday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "5"=>{"day"=>"Friday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}, "6"=>{"day"=>"Saturday", "open(1i)"=>"2011", "open(2i)"=>"8", "open(3i)"=>"24", "open(4i)"=>"10", "open(5i)"=>"00", "close(1i)"=>"2011", "close(2i)"=>"8", "close(3i)"=>"24", "close(4i)"=>"19", "close(5i)"=>"00", "closed"=>"0"}}, 
  #      "billing_method_attributes"=>{
  #        "card_number"=>"", 
  #        "security_code"=>"", 
  #        "card_expiration(3i)"=>"8", 
  #        "card_expiration(2i)"=>"10", 
  #        "card_expiration(1i)"=>"2011", 
  #        "card_type"=>"Visa", 
  #        "account_holder"=>""
  #      }, 
  #      "bank_account_attributes"=>{
  #        "institution"=>"Bank of Commerce", 
  #        "account"=>"123456789012", 
  #        "routing"=>"123456789"
  #      }, 
  #    },
  #    "user" => {
  #      "id" => user.id,
  #      "first_name" => "Fred",
  #      "last_name" => "Flintstone",
  #      "contact_phone" => "123-123-1234",
  #      "vendor_terms" => "1"
  #    },
  #    "assignment" => {
  #      "title" => "Stone Worker"
  #    }
  #  }
  #  assert_no_difference 'Vendor.count', "Vendor" do
  #    assert_difference 'Location.count', 1, "Location" do
  #      assert_difference 'Link.count', 2, "Link" do
  #        assert_no_difference 'Tag.count', "Tags" do
  #          assert_difference 'TimeSlot.count', 7, "TimeSlots" do
  #            assert_difference 'SpeedMenuAccount.count', 1, "SpeedMenuAccount." do
  #              assert_difference 'BillingMethod.count', 1, "BillingMethod" do
  #                assert_difference 'BankAccount.count', 1, "BankAccount" do
  #                  assert_no_difference 'User.count', "User" do
  #                    post :register, params
  #                  end
  #                end
  #              end
  #            end
  #          end
  #        end
  #      end
  #    end
  #  end

  #  assert_nil Vendor.last.registration_token

  #  assert_equal "Thank you! Your application is being reviewed!", flash[:notice]
  #  assert_redirected_to root_path
  #end

  #test "should get admin" do
  #  user = Factory.create :user
  #  get :admin, nil, { :user_id => user.id }
  #  assert_response :success
  #end
end

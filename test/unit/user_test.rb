require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(:first_name => "Fred", :last_name => "Flintstone",
                     :email => "fred@flintstones.com", :cell_phone => "123-123-1234",
                     :password => "password", :contact_phone => "123-123-1234",
                     :vendor_terms => true)

    vendor = Factory.create(:vendor)
    role = vendor.roles.build(user: @user, active: true, roletype_id: Role::VENDOR_EXEC)
    vendor.save!
  end

  test "valid with valid attributes" do
    assert @user.valid?
  end

  test "invalid without first name" do
    @user.first_name = nil
    assert !@user.valid?
  end

  test "invalid without last name" do
    @user.last_name = nil
    assert !@user.valid?
  end

  test "invalid with no email address" do
    @user.email = nil
    assert !@user.valid?
  end

  test "invalid if email not unique" do
    @user.save!
    assert !User.new(:email => @user.email).valid?
  end

  test "invalid with invalid email" do
    ['fred.flintstones.com','fred@flintstones','duck', '123'].each do |email|
      @user.email = email
      assert !@user.valid?
    end
  end

  test "invalid without unique phone" do
    @user.save!
    assert !User.new(:email => "some@email.com", :cell_phone => @user.cell_phone).valid?
  end

  #test "invalid without formatted phone" do
  #  check_phone_formatted :cell_phone
  #end
  
  def check_phone_formatted(attr)
    ['abc'].each do |phone|
      @user.send "#{attr.to_s}=", phone
      assert !@user.valid?
    end
    ['123.123.1234','123-123-1234','(123)123-1234',
     '123 123 1234','(123) - 123 - 1234',
     '1kgkgjh23 123 1234'].each do |phone|
      @user.send "#{attr.to_s}=", phone
      assert @user.valid?
    end
  end

  #test "invalid without 10 digit phone" do
  #  check_ten_digit :cell_phone
  #end

  def check_ten_digit(attr)
    ['123','12345678'].each do |phone|
      @user.send "#{attr.to_s}=", phone
      assert !@user.valid?
    end
  end

  #test "invalid without >=6 character password" do
  #  @user.password = "abc45"
  #  assert !@user.valid?
  #end

  test "invalid without matching confirmation on create" do
    @user.password = "password"
    @user.password_confirmation = "password2"
    assert !@user.valid?
  end

  #test "invalid without contact_number if connected to a vendor on update" do
  #  @user.contact_phone = nil
  #  assert !@user.valid?
  #end

  #test "invalid without formated contact phone" do
  #  check_phone_formatted :contact_phone
  #end

  #test "invalid without 10 digit contact phone" do
  #  check_ten_digit :contact_phone
  #end

  #test "invalid without terms if connected to a vendor on update" do
  #  @user.vendor_terms = false
  #  assert !@user.valid?
  #end

  test "#authenticate" do
    @user.save!
    assert @user.authenticate("password")
  end

  test "#send_password_reset should generate token and send email" do
    @user.save!
    @user.send_password_reset
    assert @user.password_reset_token
    assert @user.password_reset_sent_at
    assert !ActionMailer::Base.deliveries.empty?
  end

  def test_set_mobile_token
    user = Fabricate(:user)
    assert user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
    assert_equal 'dev123', user.mobile_token.device_uid
    assert_equal 'ios/DEVELOPMENT', user.mobile_token.version_uid
    assert user.mobile_token.present?
  end

  def test_set_mobile_token_with_invalid_device_uid
    user = Fabricate(:user)
    assert !user.set_mobile_token(device_uid: '', version_uid: 'ios/DEVELOPMENT')
    assert user.mobile_token.errors.present?
    assert user.mobile_token.token.blank?
  end

  def test_set_mobile_token_with_invalid_version_uid
    user = Fabricate(:user)
    assert !user.set_mobile_token(device_uid: 'dev123', version_uid: 'old')
    assert user.mobile_token.errors.present?
    assert user.mobile_token.token.blank?
  end
end

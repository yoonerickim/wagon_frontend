class User < ActiveRecord::Base
  include Sanitizers
  has_secure_password
  acts_as_mappable

  with_options dependent: :destroy do
    has_many :roles
    has_many :spots, :as => :addressable
    has_many :saved_cards
    has_one :mobile_token
    has_many :geometries, :class_name => 'UserGeometry', :order => 'created_at DESC'
    # for delivery contractors 
    has_many :delivery_hours, order: 'id'
    has_one :bank_account
  end

  has_many :vendors, :through => :roles
  has_many :locations, :through => :roles
  has_many :orders, :order => 'created_at'
  has_many :order_notes 
  has_many :assigned_orders, class_name: 'Order', foreign_key: :assigned_to_id
  has_many :contractor_orders, class_name: 'Order', foreign_key: :contractor_id
  has_many :activities
  has_many :billing_activities, :order => 'created_at ASC'
  
  attr_accessor :email_only, :is_vendor_signup

  accepts_nested_attributes_for :spots
  accepts_nested_attributes_for :saved_cards
  accepts_nested_attributes_for :delivery_hours
  accepts_nested_attributes_for :bank_account

  attr_protected :password_digest

  before_validation :sanitize
  before_validation :secure_password_digest
  after_create :no_password
  after_create :send_welcome_email
  after_create :set_cohort_id
  after_save :create_usa_epay_customer

  #validates :password, :length => { :minimum => 6, :if => Proc.new { |u| u.password.present? } }
  validates :first_name, :presence => true, :if => Proc.new { |u| u.email_only.blank? }
  validates :last_name, :presence => true, :if => Proc.new { |u| u.email_only.blank? }
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :cell_phone, :uniqueness => true, :length => { :is => 10, :allow_nil => true }, :if => Proc.new { |u| u.email_only.blank? }
  #validates :contact_phone, :length => { :is => 10, :allow_blank => true }
  #validate :must_have_contact_phone
  #validate :must_accept_vendor_terms

  serialize :delivery_boundaries  

  scope :location_only, where(
    :user => {
      :roles => {
        :roletype_id => Role::LOCATION_STAFF
      }
    }
  )

  scope :vendor_only, where(
    :user => {
      :roles => {
        :roletype_id => Role::VENDOR_STAFF
      }
    }
  )

  scope :contractors, includes(:roles).where( roles: { roletype_id: Role::DELIVERY_CONTRACTOR })
  scope :active_and_clocked_in_couriers, includes(:roles).where('clocked_in' => true).where('roles' => {'roletype_id' => Role::DELIVERY_CONTRACTOR, 'active' => true} )
  scope :superusers, includes(:roles).where(roles: { roletype_id: Role::SUPER_USER })
  scope :deliverers, includes(:roles).where(roles: { roletype_id: Role::LOCATION_STAFF })
  scope :aging_alerts, where(aging_alert: true)

  # Public: Declare the roles for this user.
  #
  # Declarative Authorization requirement.
  #
  # Returns an array of symbols of all roles.
  def role_symbols
    role_names = roles.reject{|role| !role.active? }.map(&:type).to_set
    role_names.map { |name| name.gsub(/\s/,'').underscore.to_sym } << :customer
  end

  def geometry 
    geometries.first rescue nil 
  end

  def should_track
    clocked_in or assigned_orders.active.present? or orders.active.tracking_user.present?
  end

  def active_orders
    orders.active.all
  end

  def order_queue
    assigned_orders.active.all
  end

  # Public: Test if the user has any roles. Thus any user with roles
  # passes the prelimary test to view view vendors and locations.
  #
  def has_vendors_or_locations?
    !roles.empty?
  end
  
  # Public: Test if user is a super user.
  # 
  # Returns true if a super user.
  def super_user?
    role_symbols.include? :super_user
  end
  alias_method :is_super_user?, :super_user?

  # Public: Get all associated vendors.
  #
  # Associated vendors are those either directly associated
  # by roles or those through associated locations.
  #
  # Returns a sorted array of vendors by name.
  def associated_vendors
    if super_user?
      Vendor.order('name').all
    else
      # TODO this could be reimplemented with a SQL query (performance)
      all_vendors = Set.new vendors
      locations.each do |location|
        all_vendors.add location.vendor
      end
      all_vendors.to_a.sort_by { |vendor| vendor.name }
    end
  end
  
  # TODO change this to il8n
  HUMANIZED_ATTRIBUTES = {
    :password_digest => "Password"
  }
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Public: Get the fill name of the user.
  #
  def name
    [first_name, last_name].join ' '
  end

  def email=(user_email)
    user_email = user_email.downcase if user_email.respond_to?(:downcase)
    write_attribute :email, user_email
  end

  
  # Public: Set a user's current location geometry.
  #
  # Returns true for successful, false for failure, and nil user not saved.
  def set_geometry(lat, lng)
    unless id.nil?
      # if self.geometry.nil?
      #   build_geometry
      # end
      # self.geometry.update_attributes(lat: lat, lng: lng)
      UserGeometry.create(lat: lat, lng: lng, user_id: id)
      self.lat = lat
      self.lng = lng
      self.save 
    end
  end

  def geometry_data
    data = []
    if geometry.present?
      data << %Q|data-user-lat="#{geometry.lat}"|
      data << %Q|data-user-lng="#{geometry.lng}"|
    end
    data.join(' ').html_safe
  end

  X = 0
  Y = 1

  # Public: Test if the delivery_boundaries contains the point.
  #
  # TODO: Make this inline C.
  #
  # Returns false if delivery_boundaries not set or they do not contain the point.
  def boundaries_contain?(coordinates)
    result = false
    if delivery_boundaries.present?
      comparison = delivery_boundaries.length - 1

      delivery_boundaries.each_with_index do |point, index|
        if ((point[Y] < coordinates[Y] && delivery_boundaries[comparison][Y] >= coordinates[Y] ||
             delivery_boundaries[comparison][Y] < coordinates[Y] && point[Y] >= coordinates[Y]) && 
             (point[X] <= coordinates[X] || delivery_boundaries[comparison][X] <= coordinates[X]))
          if (point[X]+(coordinates[Y]-point[Y])/(delivery_boundaries[comparison][Y]-point[Y])*
              (delivery_boundaries[comparison][X]-point[X]) < coordinates[X])
            result ^= true;
          end
        end
        comparison = index
      end
    end
    result
  end
  
  def self.all_available_contractors_at(c1)
    contractors = []
    users = active_and_clocked_in_couriers.within(20, :origin => c1).all
    for user in users.sort_by_distance_from(c1)
      contractors << user if user.boundaries_contain?(c1)  
    end
    contractors 
  end

  def self.contractors_available?(origin)
    contractors = all_available_contractors_at([origin[:lat].to_f, origin[:lng].to_f])
    
    if contractors.blank? and origin.present? 
      Activity.create(:lat => origin[:lat], :lng => origin[:lng], :activity_type => Activity::NO_COVERAGE)
    end
    
    not contractors.blank?
  end
  
  def self.all_available_contractors_containing(c1, c2)
    contractors = []
    users = active_and_clocked_in_couriers.within(20, :origin => c1).all    
    for user in users.sort_by_distance_from(c1)
      puts user
      contractors << user if user.boundaries_contain?(c1) and user.boundaries_contain?(c2)  
    end
    contractors 
  end

  def set_password_reset
    set_token(:password_reset_token)
  end

  # Set attributes to reset a password and queue
  # a email message to notify the user.
  #
  def send_password_reset
    set_password_reset
    self.password_reset_sent_at = Time.zone.now
    save!
    log_and_notify "Sending password reset for User ##{id}" do
      PasswordMailer.reset(self.id).deliver
    end
  end

  def send_welcome_email
    if email_only.blank? and is_vendor_signup.blank?
      set_password_reset
      self.password_reset_sent_at = Time.zone.now
      save!
      log_and_notify "Sending welcome for User ##{id}" do
        UserMailer.welcome(self.id).deliver
      end
    end
  end

  def set_mobile_token(params)
    mobile_token.destroy if mobile_token.present?
    token = create_mobile_token(params)
    token.persisted?
  end

  def create_usa_epay_customer
    # only create a customer if non-existent, or if not an email only pre-reg thing
    if self.usa_epay_customer_id.blank? and self.email_only.blank? 
      options = {id: self.id, billing_address: {first_name: self.first_name, last_name: self.last_name}}
      response = GATEWAY.add_customer(options)
      if response.success?
        self.usa_epay_customer_id = response.message
        save
      else
        logger.warn "Could not create USA EPAY CUSTOMER for user: #{self.id}"
        logger.warn response.inspect
      end
    end
  end

  # Public: Set delivery boundaries from a json string.
  #
  # To clear pass an empty array: []
  #
  def delivery_boundaries_json=(boundaries)
    begin
      self.delivery_boundaries = JSON.parse boundaries if boundaries =~ /\A\[.*\]\z/
    rescue JSON::ParserError => e
      logger.warning "#{e.message} while parsing user delivery_boundaries."
    end
  end
  
  def is_delivery_contractor?
    role = Role.where(:active => true, :roletype_id => Role::DELIVERY_CONTRACTOR, :user_id => id).first
    if role.present? 
      return true
    else
      return false 
    end
  end
  
  def self.construct_and_send_generic_message(user, params)    
    content = ''


    if user.first_name.present? and user.last_name.present? and user.last_name != 'change_me'           
      
      if params[:greeting_prefix].present? 
        content += params[:greeting_prefix].strip + ' '            
      end
            
      content += user.first_name
      the_to = "\"#{user.first_name} #{user.last_name}\" <#{user.email}>"
      content += "," + "\n" + "\n"      
    else
      #not addding this
      #content += user.email.scan(/(.+?)@/)[0][0] rescue nil 
      the_to = user.email
    end  
    content += params[:body]    
       
    log_and_notify "Sending mass email out to #{the_to}" do
      UserMailer.generic_message(the_to, params[:subject], content).deliver                      
    end
  
  end
  
  def set_cohort_id
    self.cohort_id = "v1.3"
    self.save
  end

  private

  # Private: Before create hook. Set password reset if the user was created without
  # a password.
  #
  # Currently this is applicable when a user registers in the checkout form.
  # Don't send password thing if it's a pre-reg signup 
  
  def no_password
    #turning this off for now 
    #send_welcome_email unless email_only.present? || (password.present? && password == password_confirmation) 
  end

  def sanitize
    self.cell_phone = strip_non_digits(self.cell_phone)
    self.contact_phone = strip_non_digits(self.contact_phone)
  end

  # Generate a random, unique token and set the designated 
  # column to that value.
  #
  def set_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(64) 
    end while self.class.exists?(column => self[column])
  end

  # If the password_digest is blank, create a random password.
  #
  def secure_password_digest
    self.password = SecureRandom.urlsafe_base64(16) if password_digest.blank?
  end

  # Validate user has a contact phone on updates only if attached to a
  # vendor. TODO or a location.
  def must_have_contact_phone
    errors[:contact_phone] << "is required" if self.persisted? && self.vendors.count > 0 && self.contact_phone.blank?
  end

  # Validat user accepts vendor terms on updates only if attached to a 
  # vendor. TODO or a location
  def must_accept_vendor_terms
    errors[:vendor_terms] << "is required" if self.persisted? && self.vendors.count > 0 && !self.vendor_terms
  end
  
  # Public: Raise if cannot find user.
  #
  class RecordNotFound < StandardError; end

  # Public: Raise if safe mode cannot be entered.
  class UnauthorizedLiveLocation < StandardError; end
end

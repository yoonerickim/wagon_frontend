class Vendor < ActiveRecord::Base
  include Sanitizers

  has_many :roles
  has_many :users, :through => :roles
  has_many :locations, :dependent => :destroy
  has_many :links, :as => :linkable
  image_accessor :logo_image

  accepts_nested_attributes_for :roles
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :links, :allow_destroy => true, 
    :reject_if => proc { |attributes| 
      attributes[:value].blank? && Link::OPTIONAL_NAMES.include?(attributes[:name]) 
    }

  validates :name, :presence => true
  validates_property :format, :of => :logo_image, :in => [:jpeg, :jpg, :png, :gif, :JPEG, :JPG, :PNG, :GIF]
  validate :only_one_user, :on => :create

  before_validation :sanitize
  before_create :set_registration_token
  before_update :remove_registration_token # TODO should be after save somehow...

  def to_param
    [ id,
      name.gsub(/\W/,'').underscore
    ].join('-').gsub(/_/,'-')
  end

  HUMANIZED_ATTRIBUTES = {
    'roles.user.first_name'.to_sym => "First name",
    'roles.user.last_name'.to_sym => "Last name",
    'roles.user.email'.to_sym => "Email"
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # Public: Set if object can be registerd or not. Defaults to false.
  #
  attr_writer :registerable

  # Public: Test if vendor can be registered.
  #
  def registerable?
    @registerable ||= false
  end
  
  # Using this method to parse down the initial signup process for vendors, but still want things showing up in their dashboard edit pages. 
  #
  def has_completed_final_signup? 
    if description.present? 
      return true
    else
      return false
    end  
  end

  # Sends email welcoming user/vendor with a link to set up
  # vendor and user's password.
  #
  def send_welcome_email
    log_and_notify do
      VendorMailer.welcome(self.id).deliver
    end
  end
  
  def send_admin_notification_email
    log_and_notify do
      VendorMailer.admin_notification(self.id).deliver
    end
  end

  # Public: Set all locations active/inactive.
  #
  def active=(status)
    locations.each do |location|
      location.active = status
      location.save!(validate: false)
    end
    active
  end

  def active
    locations.reduce(true) {|memo, location| location.active? }
  end

  private
  # must be called before validations!
  def sanitize
    self.phone = strip_non_digits(self.phone)
  end

  # Block more than one user added on creation.
  #
  def only_one_user
    errors[:base] << "Only one user may be added." if self.roles.size > 1
  end

  # Create a digest so vendor/user can log in to finish
  # creating account.
  #
  def set_registration_token
    set_token(:registration_token) if registerable?
  end

  # Generate a random, unique token and set the designated 
  # column to that value.
  #
  def set_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(32)[0,20]
    end while self.class.exists?(column => self[column])
  end

  # Nullify token.
  #
  def remove_registration_token
    self.registration_token = nil
  end

end

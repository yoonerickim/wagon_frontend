require 'net/http'
require 'uri'

# Location
#
# Fields:
# description - public description
# phone - public phone
# dine_in - true if available
# take_out - true if available
# address_delivery - true if available
# spot_delivery - true if available
# openmenu_url - url for xml file
# use_openmenu_hours - true to mirror hours on openmenu
# menu_url - url for HTS admin/superuser to look at and 
#   manually create create menu for location
# use_hours_for_delivery_hours - true if delivery should
#   location hours
# integrate_pos - true if using SD
# delivery_radius - distance of delivery radius in miles
# delivery_boundaries - 
# subtledata_location_id - id for Subtle Data api
# tax_rate - tax rate for location - set by db default
#
class Location < ActiveRecord::Base
  include Sanitizers

  PACIFIC_TIME = 'Pacific Time (US & Canada)'
  MOUNTAIN_TIME = 'Mountain Time (US & Canada)'
  CENTRAL_TIME = 'Central Time (US & Canada)'
  EASTERN_TIME = 'Eastern Time (US & Canada)'
  HAWAII_TIME = 'Hawaii'
  ALASKA_TIME = 'Alaska'

  TIME_ZONES = [PACIFIC_TIME, MOUNTAIN_TIME, CENTRAL_TIME, EASTERN_TIME, HAWAII_TIME, ALASKA_TIME]

  X = 0
  Y = 1

  attr_accessor :menu_type # for radio button and JS

  belongs_to :vendor

  with_options dependent: :destroy do
    has_many :links, :as => :linkable
    has_many :hours, order: 'id'
    has_many :delivery_hours, order: 'id'
    has_many :menus, dependent: :destroy, autosave: true
    has_many :menu_uploads, :class_name => 'Document', :as => :documentable
    has_many :roles
    has_many :tag_links
    has_one :address, :as => :addressable
    has_one :pos_account, :class_name => "SpeedMenuAccount"
    has_one :bank_account
    has_one :billing_method
  end

  has_many :menu_items, through: :menus, source: :items
  has_many :menu_groups, :through => :menus, :source => :groups
  has_many :tags, :through => :tag_links
  has_many :users, :through => :roles
  has_many :orders
  has_many :customers, :through => :orders, :source => :user, :group => 'user_id'

  attr_accessor :delivery_minimum_amount
  attr_accessor :delivery_fee_amount

  accepts_nested_attributes_for :hours
  accepts_nested_attributes_for :delivery_hours
  accepts_nested_attributes_for :menus
  accepts_nested_attributes_for :menu_uploads, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :vendor
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :pos_account#, :reject_if => :all_blank
  accepts_nested_attributes_for :bank_account, 
    reject_if: lambda {|attributes| attributes[:account].blank? || attributes[:routing].blank? }
  accepts_nested_attributes_for :billing_method#, :reject_if => card blank
  accepts_nested_attributes_for :links, :allow_destroy => true,
    :reject_if => proc { |attributes| attributes[:value].blank? &&
      Link::OPTIONAL_NAMES.include?(attributes[:name]) }

  acts_as_mappable :through => :address
  delegate :lat, :lng, :to => :address

  validates :phone, :presence => true, :length => { :in => 10..11 }
  validates :sms_phone, :length => { :is => 10, :allow_blank => true }
  validates :fax_number, :length => { :is => 10, :allow_blank => true }
  validates :time_zone, inclusion: { in: TIME_ZONES }
  validates :menu_url, :url => { :allow_blank => true }
  validates :openmenu_url, :url => { :allow_blank => true }
  validates :delivery_minimum_amount, 
    numericality: { greater_than_or_equal_to: 5.00, allow_nil: true }, on: :update
  validates :delivery_fee_amount, numericality: { allow_nil: true }, on: :update
  validate :at_least_one_delivery_type

  before_validation :sanitize
  after_validation :build_openmenu, if: :openmenu_url_changed?

  before_save :convert_delivery_minimum_amount
  before_save :convert_delivery_fee_amount

  serialize :delivery_boundaries

  after_initialize do |location|
    if location.use_hours_for_delivery_hours.nil?
      location.use_hours_for_delivery_hours = true
    end
    #location.build_bank_account unless bank_account.present?
  end

  def to_param
    [ id, 
      vendor.name.gsub(/\W/,'').underscore, 
      address.street1.gsub(/\W/,'').underscore
    ].join('-').gsub(/_/, '-')
  end

  scope :active, where(active: true)

  # Public: Find all locations with a term in name, description. TODO Also need to
  # be able to search by food served.
  #
  def self.search(q)
    if q.present?
      includes(:vendor, :tags, :menus => [:items]).
        where('vendors.name ILIKE ? OR menu_items.name ILIKE ? OR tags.name ILIKE ?', 
              "%#{q}%", "%#{q}%", "%#{q}%")
    else
      scoped
    end
  end

  # Public: Find all locations per delivery type
  #
  # type - can be a single type or an array of types.
  #
  # Returns a scoped query.
  def self.applicable(type)
    query = scoped
    Array(type).each do |type|
      case type
      when Order::SPOT_DELIVERY
        query.where(spot_delivery: true)
      when Order::ADDRESS_DELIVERY
        query.where(address_delivery: true)
      when Order::TAKE_OUT
        query.where(take_out: true)
      when Order::DINE_IN
        query.where(dine_in: true)
      when Order::CUSTOM || Order::CONTRACTOR
        query.where(contractor_delivery: true)
      end
    end
    query
  end

  def self.close_to(coordinates, options={ within: 50 })
    includes(:address).within(options[:within], :origin => coordinates)
  end

  # Public: Find all locations within a bounding box.
  #
  # Returns a scope.
  def self.bounds(northeast, southwest)
    scoped.includes(:address).
      where('? <= addresses.lat AND addresses.lat <= ? AND ? <= addresses.lng AND addresses.lng <= ?',
            southwest[:lat], northeast[:lat], southwest[:lng], northeast[:lng])
  end

  # Public: Get full name.
  #
  # #full_display_name is an alias for this method.
  #
  def name
    [vendor.name, address.street1].reject(&:blank?).join(' - ')
  end
  alias_method :full_display_name, :name
  
  # Public: Set tag_ids for location. Does not save the 
  # records. You must manually call save.
  #
  # ids - Single tag_id or an array of tag_ids.
  # 
  # Returns the assigned array of tag_ids.
  def tag_ids=(ids)
    Array(ids).each do |id|
      tl = self.tag_links.build(:tag_id => id)
    end
  end

  # Public: Return tag_ids for a location.
  #
  # Returns an array.
  def tag_ids
    tags.collect { |t| t.id }
  end

  # Join tag names into string for virtual attribute
  #
  def tag_names
    @tag_names || tags.map(&:name).join(' ')
  end

  # Build the objects needed for the registration form.
  #
  def build_registration_objects
    build_address unless address.present?
    TimeSlot::DAYS.each { |day|
      hours.build(day: day) unless hours.exists?(day: day)
    }
    TimeSlot::DAYS.each { |day|
      delivery_hours.build(day: day) unless delivery_hours.exists?(day: day)
    }
    build_pos_account unless pos_account.present?
    build_billing_method unless billing_method.present?
    build_bank_account unless bank_account.present?
    Link::LOCATION_NAMES.each { |link|
      links.build(name: link) unless links.exists?(name: link)
    }
    menu_uploads.build
  end

  def todays_hours
    now = Time.now.utc.in_time_zone(time_zone)
    hour = hours.where(day: now.strftime("%A")).first
    hour = Hour.always_open if hour.nil?
    hour
  end
       
  def todays_delivery_hours
    now = Time.now.utc.in_time_zone(time_zone)
    hour = delivery_hours.where(day: now.strftime("%A")).first
    hour = Hour.always_open if hour.nil?
    hour
  end

  # Public: Test if store is open.
  #
  # seconds_since_midnight - seconds since midnight in the local time zone
  #
  # Returns true if delivering.
  def open?(seconds_since_midnight=nil)
    seconds_since_midnight = self.seconds_since_midnight if seconds_since_midnight.nil?
    todays_hours.in_hours?(seconds_since_midnight)
  end

  # Public: Test if store is delivering.
  #
  # seconds_since_midnight - seconds since midnight in the local time zone
  #
  # Returns true if delivering.
  def delivering?(seconds_since_midnight=nil)
    seconds_since_midnight = self.seconds_since_midnight if seconds_since_midnight.nil?
    return open?(seconds_since_midnight) if use_hours_for_delivery_hours?
    todays_delivery_hours.in_hours?(seconds_since_midnight)
  end

  # Public: Get the seconds since midnight at this locations
  # time_zone.
  #
  # Returns seconds.
  def seconds_since_midnight
    Time.now.in_time_zone(self.time_zone).seconds_since_midnight
  end

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

  # Public: Test if the coordinates are out of delivery (radius or bounds)
  #
  # Returns true if not in delivery area.
  def out_of_delivery?(coordinates)
    !inside_delivery?(coordinates)
  end

  # Public: Test if the coordinates are inside delivery (radius or bounds)
  #
  # Returns true if not in delivery area.
  def inside_delivery?(coordinates)
    if delivery_boundaries.present?
      result = boundaries_contain?(coordinates)
      self.distance = distance_from(coordinates)
      result
    else
      if delivery_radius.present? 
        self.distance = distance_from(coordinates)
        distance < delivery_radius 
      else
        false
      end
    end
  end
  # Public: Set the distance to a coordinate pair for sorting purposes
  #
  attr_writer :distance

  # Public: Get the set distance for sorting purposes.
  #
  # coordinates - Optional. Provide a backup if distance was
  # not previously set.
  #
  # Returns distance set or distance from coordinates.
  def distance(coordinates=nil)
    @distance || distance_from(coordinates)
  end

  attr_accessor :delivery_via_contractor
  attr_accessor :delivery_via_spot

  # Public:
  #
  # options[:to] - array of lat/lng
  #
  # Also sets delivery_via_contractor and delivery_via_spot if appropriate.
  #
  def can_deliver?(options={})
    yes = spot_delivery? && inside_delivery?(options[:to])
    self.delivery_via_spot = true if yes
    if !yes && contractor_delivery? && contractor_available(options)
      self.delivery_via_contractor = true
      yes = true
    end
    yes
  end

  def contractor_available(options={})
    # NOTE This won't scale.... :-(
    # TODO filter by location.
    unless @contractor_available.present?
      User.contractors.where(clocked_in: true).find_each do |contractor|
        if (contractor.boundaries_contain?(options[:to]) &&
            contractor.boundaries_contain?(address.coordinates))
          @contractor_available = contractor
          break
        end
      end
    end
    @contractor_available
  end

  def usa_epay_customer_id
    if read_attribute :usa_epay_customer_id
      return read_attribute :usa_epay_customer_id
    else
      create_usa_epay_customer
    end
  end

  # Temporary Hack: Get all subtledata menus
  #
  def menu
    menu = {}
    categories = SD.get_menu_categories(:location_id => subtledata_location_id, 
                                        :category => 0,
                                        :in_store => 1,
                                        :delivery => 1,
                                        :take_out => 1 )
    categories.each do |category|
      menu[category] = SD.get_menu_items(:location_id => subtledata_location_id,
                                               :category => category.id,
                                               :in_store => 1,
                                               :delivery => 1,
                                               :take_out => 1 )
    end
    menu
  end

  # Public: Parse openmenu xml.
  #
  def build_openmenu
    openmenu = parse_openmenu
    if openmenu.present?

      # clean out any old menus
      # TODO test for a concurrent order and parse!!!
      #self.menus.destroy_all
      #
      # TODO track updated record ids, then psudo DELETE all NOT IN [1,2,....]
      # TODO Move to model classes

      #current_menu_ids = []
      #current_menu_group_ids = []
      #current_menu_item_ids = []
      openmenu.menus.each do |_menu|
        menu_attributes = {
          name: _menu.name,
          description: _menu.description,
          start_at: _menu.duration.start.present? ? Time.parse(_menu.duration.start) : nil,
          end_at: _menu.duration.end.present? ? Time.parse(_menu.duration.end) : nil
        }
        menu = menus.find_or_create_by_uid(_menu.uid, menu_attributes)
        if menu.persisted?
          menu.update_attributes(menu_attributes)
          #current_menu_ids << menu.id
        end

        _menu.groups.each do |_group|
          group_attributes = { name: _group.name, description: _group.description }
          group = menu.groups.find_or_create_by_uid(_group.uid, group_attributes)
          group.update_attributes(group_attributes) if group.persisted?

          if _group.options
            _group.options.each do |_option|
              option_attributes = { information: _option.information }
              option = group.options.find_or_create_by_name(_option.name, option_attributes)
              option.update_attributes(option_attributes) if option.persisted?

              _option.items.each do |_item|
                item_attributes = { additional_cost: _item.additional_cost * 100 }
                item = option.items.find_or_create_by_name(_item.name)
                item.update_attributes(item_attributes) if item.persisted?
              end
            end
          end

          _group.items.each do |_item|
            item_attributes = {
              name: _item.name,
              description: _item.description,
              price: _item.price * 100
            }
            item = group.items.find_or_create_by_uid(_item.uid, item_attributes)
            item.update_attributes(item_attributes) if item.persisted?

            if _item.sizes
              _item.sizes.each do |_size|
                size_attributes = {
                  description: _size.description,
                  price: _size.price * 100,
                  calories: _size.calories 
                }
                size = item.sizes.find_or_create_by_name(_size.name)
                size.update_attributes(size_attributes) if size.persisted?
              end
            end

            if _item.options
              _item.options.each do |_option|
                option_attributes = { information: _option.information }
                option = item.options.find_or_create_by_name(_option.name)
                option.update_attributes(option_attributes) if option.persisted?

                _option.items.each do |_item|
                  item_attributes = { additional_cost: item.additional_cost * 100 }
                  item = option.items.find_or_create_by_name(_item.name)
                  item.update_attributes(item_attributes) if item.persisted?
                end
              end
            end

            if _item.tags
              _item.tags.each do |_tag|
                tag = ItemTag.find_or_create_by_name(_tag.name)

                unless item.tags.include?(tag)
                  link = item.item_tag_links.build
                  link.item_tag = tag
                end
              end
            end # if _item.tags

          end
        end
      end
    end
  end

  def time_offset
      Time.now.utc.in_time_zone(time_zone).utc_offset
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

  private

  # Private: Sanitize inputs.
  #
  # Must be called before validations!
  #
  def sanitize
    self.phone = strip_non_digits(self.phone)
    self.sms_phone = strip_non_digits(self.sms_phone)
    self.fax_number = strip_non_digits(self.fax_number)
    self.delivery_minimum_amount.gsub! /\$/, '' if delivery_minimum_amount.present?
    self.delivery_fee_amount.gsub! /\$/, '' if delivery_fee_amount.present?
  end

  def convert_delivery_minimum_amount
    self.delivery_minimum = Float(delivery_minimum_amount) * 100 if delivery_minimum_amount.present?
  end

  def convert_delivery_fee_amount
    self.delivery_fee = Float(delivery_fee_amount) * 100 if delivery_fee_amount.present?
  end

  # Private: Create usa_epay customer id
  #
  def create_usa_epay_customer
    unless read_attribute(:usa_epay_customer_id).present?
      options = {
        id: self.id, 
        billing_address: {
          company: self.name
        }
      }
      response = GATEWAY.add_customer(options)
      if response.success?
        self.usa_epay_customer_id = response.message
        save
        return read_attribute(:usa_epay_customer_id)
      else
        logger.warn "Could not create USA EPAY CUSTOMER for location: #{self.id}"
        logger.warn response.inspect
        nil
      end
    end
  end

  # Private: Get xml file.
  #
  # Returns an xml file.
  def get_xml(url)
    xml = Net::HTTP.get(URI.parse(url)) # TODO may raise errors, with net problems
  end

  # Private: Parse openmenu xml.
  #
  def parse_openmenu
    if self.openmenu_url.present? && self.errors[:openmenu_url].length == 0 

      # clean out any old menus
      # TODO test for a concurrent order and parse!!!
      #self.menus.clear

      xml = get_xml(openmenu_url)
      OpenMenu.parse(xml)
    end
  end

  # Private: Validate at least one delivery type is selected.
  #
  def at_least_one_delivery_type
    types = 0
    [:dine_in, :take_out, :address_delivery, :spot_delivery].each do |t|
      types += 1 if self[t] == true
    end
    errors.add(:base, "At least one order type must be selected") unless types > 0
  end

end

class MenuItem < ActiveRecord::Base
  default_scope order: 'id'
  belongs_to :group, :class_name => 'MenuGroup', :foreign_key => :menu_group_id
  has_one :menu, :through => :group
  has_one :location, :through => :menu

  has_many :sizes, :class_name => 'MenuSize', :dependent => :destroy
  has_many :options, :as => :optionable, :class_name => 'MenuOption', :dependent => :destroy
  # TODO tags
  
  image_accessor :image
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif, :JPEG, :JPG, :PNG, :GIF]

  validates :name, :presence => true
  # Does not seem to have access to the sizes yet..... Why?
  #validates :price, :presence => true #{ :if => :price_required? }

  accepts_nested_attributes_for :options, allow_destroy: true
  accepts_nested_attributes_for :sizes, allow_destroy: true

  scope :matching, lambda { |term| where("menu_items.name ILIKE ? OR menu_items.description ILIKE ?", "%#{term}%", "%#{term}%") }

  # Public: Find out if an item has options, either sizes, options, or
  # group options.
  #
  # Returns a boolean.
  def has_options?
    @has_options ||= self.option_count > 0 || self.sizes.size > 0
  end

  def option_count
    @option_count ||= self.options.size + self.group.options.size
  end

  def minimum_price
    case
    when sizes.present?
      self.sizes.order('price ASC').first.price
    when price.present?
      price
    else
      0
    end
  end

  # Takes 7.99 or "7.99" to set price (in cents)
  # at 799.
  #
  def dollars=(dollars)
    dollars.gsub!(/(?!\.)\D/, '') if dollars.respond_to?(:gsub!)
    self.price = (dollars.to_f)*100.floor
  end

  # Returns price in a float. 799 becomes 7.99
  #
  def dollars
    self.price.to_f/100
  end

  private

  # Public: A price is required if there are no sizes, which
  # have required prices.
  #
  # Returns true if required.
  def price_required?
    self.sizes.count == 0  
  end
end

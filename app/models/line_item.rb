#
# Cached Attributes:
# name: string - name when cached
# price: integer - price in cents when cached
#
class LineItem < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include Lock

  belongs_to :order
  belongs_to :item, class_name: 'MenuItem', foreign_key: :menu_item_id
  belongs_to :size, class_name: 'MenuSize', foreign_key: :menu_size_id
  has_one :menu, through: :item
  has_one :location, through: :item

  # options are the join table with the quanity
  #
  has_many :options, class_name: 'LineItemOption'

  # optional_items are the referenced option items
  #
  has_many :optional_items, through: :options, source: :item
  has_many :optional_options, through: :optional_items, source: :option, group: 'id'

  # item_options are the available options for the item
  #
  has_many :item_options, through: :optional_items, source: :option, group: 'menu_options.id'

  validates :quantity, presence: true, numericality: true
  validate :menu_size_present
  validate :has_required_options
  validate :order_line_items_not_locked, on: :create

  accepts_nested_attributes_for :options

  before_save :protect_if_locked

  # Public: Get the matching LineItemOption for the given MenuItem.
  #
  # item - A MenuOptionItem
  #
  # Returns the matchin or a built one.
  def option_for(item)
    self.options.select{|current| current.menu_option_item_id == item.id }.try(:first) || self.options.build
  end

  # Public: Get price
  #
  # Set options[:current] to force from associated.
  #
  # Price in cents.
  def price(options={})
    if options.has_key?(:current)
      size.present? ? size.try(:price) : item.try(:price)
    else
      read_attribute(:price) || price(current: true)
    end
  end

  # Public: Get name.
  #
  # Set options[:current] to force from associated.
  #
  # Name of item.
  def name(options={})
    if options.has_key?(:current)
      item.try(:name)
    else
      read_attribute(:name) || name(current: true)
    end
  end

  # Public: Get size name.
  #
  # Set options[:current] to force from associated.
  #
  # Name of size.
  def size_name(options={})
    if options.has_key?(:current)
      size.try(:name)
    else
      read_attribute(:size_name) || size_name(current: true)
    end
  end

  # Public: Get the subtotal for the line_item including sizes and any options.
  #
  # Returns an integer of the price.
  def subtotal
    sub = options.inject(self.price) { |price, option| price + option.subtotal }
    quantity * sub
  end

  # Public: Cache the current name/price of the line_item and propagate
  # to each option.
  #
  def cache!
    options.each(&:cache!)
    update_attributes(
      name: name(current: true),
      price: price(current: true),
      size_name: size_name(current: true)
    )
  end

  # Public: Define children to lock/unlock.
  #
  def lockble_children
    self.options
  end

  private

  # Private: Before save don't allow locked items to be saved.
  #
  def protect_if_locked
    if locked? && locked_was == true
      logger.warn "LineItem #{id}: Sanitizing locked parameters."
      self.class.column_names.reject{|name| name =~ /_at|locked/ }.each do |attribute|
        self.send(:"#{attribute}=", self.send(:"#{attribute}_was")) if send(:"#{attribute}_changed?")
      end
    end
    true
  end

  # Private: Validate menu size present?
  #
  # Valid values for menu_size_id are nil for an item
  # without sizes or a valid foreign key of a MenuSize
  #
  def menu_size_present
    errors.add(:size, 'must exist') unless (self.menu_size_id == nil) || size.present?
  end

  # Private: Validate order is not locked to save.
  #
  # Only needs to be called on create. As previously created line
  # items will already be locked.
  #
  def order_line_items_not_locked
    if self.order.present? && self.order.locked? && self.changed?
      logger.warn "\n\nLineItem #{id}: Order has been locked. Changed: #{changed_attributes.inspect}\n"
      errors.add :order, 'has been locked'
    end
  end

  # Internal: Validate required options and add errors 
  # if minimum/maximum errors are not met.
  #
  def has_required_options

    # Collect optional_options manually as some may
    # not be saved yet.
    #
    _optional_options = []
    options.each do |option|
      _optional_options << option.item.option
    end
    _optional_options.uniq!

    _optional_options.each_with_index do |option, index|

      # Find line item options for this option
      #
      line_item_options_for_option = []
      self.options.reduce(line_item_options_for_option){ |collection, line_item_option|
        option == line_item_option.option ? collection << line_item_option : collection
      }
      
      # Find total quantity of line line options
      #
      total_quantity = line_item_options_for_option.inject(0){ |sum, n|
        n.quantity.present? ? sum = sum + n.quantity : sum
      }

      # Test required minimum is met
      #
      if option.minimum.present? && total_quantity < option.minimum
        errors.add(
          :base,
          "#{option.name} must have at least #{pluralize option.minimum, 'option'}"
        )
      end

      # Test required maximum is met
      #
      if option.maximum.present? && total_quantity > option.maximum
        errors.add(
          :base,
          "#{option.name} may only have at most #{pluralize option.maximum, 'option'}"
        )
      end

    end
  end

end

class LineItemOption < ActiveRecord::Base
  include Lock

  belongs_to :line_item
  belongs_to :item, class_name: 'MenuOptionItem', foreign_key: :menu_option_item_id

  has_one :option, through: :item, source: :option

  before_save :protect_if_locked

  # Public: Get additional cost.
  #
  # Set options[:current] to force from associated.
  #
  # Returns additional cost in cents.
  def additional_cost(options={})
    if options.has_key?(:current)
      item.try(:additional_cost)
    else
      read_attribute(:additional_cost) || additional_cost(current: true)
    end
  end

  # Public: Get name.
  #
  # Set options[:current] to force from associated.
  #
  # Returns name of item.
  def name(options={})
    if options.has_key?(:current)
      item.try(:name)
    else
      read_attribute(:name) || name(current: true)
    end
  end

  # Public: Get option name.
  #
  # Set options[:current] to force from associated.
  #
  # Returns name of option.
  def option_name(options={})
    if options.has_key?(:current)
      option.try(:name)
    else
      read_attribute(:option_name) || option_name(current: true)
    end
  end

  # Public: Get the subtotal for the item.
  #
  # Return subtotal in cents
  def subtotal
    if quantity.present? && menu_option_item_id.present?
      item.additional_cost.present? ? quantity * item.additional_cost : 0
    else
      0
    end
  end

  # Public: Cache name, cost, and option name.
  #
  # Returns true if successful
  def cache!
    update_attributes(
      name: name(current: true), 
      additional_cost: additional_cost(current: true),
      option_name: option_name(current: true)
    )
  end

  private

  # Private: Don't allow locked items to be saved.
  #
  def protect_if_locked
    if locked? && locked_was == true
      self.class.column_names.reject{|name| name =~ /_at|locked/ }.each do |attribute|
        self.send(:"#{attribute}=", self.send(:"#{attribute}_was")) if send(:"#{attribute}_changed?")
      end
    end
  end

end

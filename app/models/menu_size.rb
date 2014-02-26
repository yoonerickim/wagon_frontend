class MenuSize < ActiveRecord::Base
  belongs_to :item, :class_name => 'MenuItem'

  validates :name, :presence => true
  validates :price, :presence => true

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
end

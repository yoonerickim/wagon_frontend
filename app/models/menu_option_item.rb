class MenuOptionItem < ActiveRecord::Base
  belongs_to :option, :class_name => 'MenuOption', :foreign_key => :menu_option_id

  has_many :line_item_options
  
  # Takes 7.99 or "7.99" to set additional_cost (in cents)
  # at 799.
  #
  def additional_dollars=(dollars)
    dollars.gsub!(/(?!\.)\D/, '') if dollars.respond_to?(:gsub!)
    self.additional_cost = (dollars.to_f)*100.floor
  end

  # Returns additional_cost in a float. 799 becomes 7.99
  #
  def additional_dollars
    self.additional_cost.to_f/100
  end
end

class BillingMethod < ActiveRecord::Base
  belongs_to :location

  attr_writer :required
  attr_accessor :card_number
  attr_accessor :security_code

  #validates :card_number, :presence => { :if => :billing_method_required? }
  #validates :security_code, :presence => true
  
  def required
    @required = true if @required.nil?
    @required
  end


  def billing_method_required?
    return self.location.integrate_pos == true unless self.location.nil?
    new_record? && required
  end
end

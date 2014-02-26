class SpeedMenuAccount < ActiveRecord::Base
  belongs_to :location

  attr_writer :required

  #validates :make, :presence => { :if => :account_required? }
  #validates :model, :presence => { :if => :account_required? }

  def required
    @required = true if @required.nil?
    @required
  end

  private

  def account_required?
    return self.location.integrate_pos == true unless self.location.nil?
    required
  end
end

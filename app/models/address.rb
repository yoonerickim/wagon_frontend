class Address < ActiveRecord::Base
  acts_as_mappable
  belongs_to :addressable, :polymorphic => true

  def name
    name = "(#{[street1, street2, city, state, zip, lat, lng].reject{|f| f.blank? }.join(', ')})"
    name = "#{nickname} - #{name}" if nickname.present?
    name
  end

  def spot_formatted
    if spot?
      "(#{[lat, lng].reject{|f| f.blank? }.join(', ')})"
    else
      [street1, street2, city, state, zip].reject{|f| f.blank? }.join(', ')
    end
  end

  def spot?
    (lat || lng).present?
  end

  def row_id
    "spot-#{id}"
  end

  def coordinates
    [lat, lng]
  end

  # NOTE: may need these for sign up process
  #
  #validates :street1, :presence => { :if => :address_required? }
  #validates :city, :presence => { :if => :address_required? }
  #validates :state, :presence => { :if => :address_required? }
  #validates :zip, :presence => { :if => :address_required? }, :numericality => { allow_nil: true }
  #validates :nickname, :presence => { :if => :nickname_required? }

  #private

  #def address_required?
  #  addressable && addressable.class != User || (self.lat.blank? || self.lng.blank?)
  #end

  #def nickname_required?
  #  addressable && addressable.class == User
  #end
end

# DeliverySpot encapsulates a delivery location.
#
# This can be either a Spot or Address location.
#
# Fields:
# lat - initially set by params[:lat] in order/place
# lng - initially set by params[:lng] in order/place
# reverse_address - initially set by params[:address] in order/place
# use_reverse - (boolean) default true. If a user specifies address,
#   change to false.
# street1/street2/city/state/zip - if needed to be manually set by
#   user when submitting the order. (Meaning the reverse geocoded
#   address was wrong.)
#
class DeliverySpot < ActiveRecord::Base
  belongs_to :order

  def address
    [street1, street2, city, state, zip].reject{|entry| entry.blank?}.join ', '
  end

  def coordinates
    [lat, lng]
  end
end

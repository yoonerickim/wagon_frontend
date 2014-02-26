class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor
  belongs_to :roletype
  belongs_to :location
  accepts_nested_attributes_for :user

  SUPER_USER = 1
  VENDOR_EXEC = 2
  VENDOR_ADMIN = 3
  LOCATION_EXEC = 4
  LOCATION_ADMIN = 5
  LOCATION_DELIVERY_STAFF = 6
  LOCATION_SERVER_STAFF = 7
  DELIVERY_CONTRACTOR = 8 

  TYPES = {
    SUPER_USER => 'Super User',
    VENDOR_EXEC => 'Vendor Exec',
    VENDOR_ADMIN => 'Vendor Admin',
    LOCATION_EXEC => 'Location Exec',
    LOCATION_ADMIN => 'Location Admin',
    LOCATION_DELIVERY_STAFF => 'Location Delivery Staff',
    LOCATION_SERVER_STAFF => 'Location Server Staff', 
    DELIVERY_CONTRACTOR => 'Delivery Contractor'
  }
  
  VENDOR = [
    ['Vendor Exec', VENDOR_EXEC], 
    ['Vendor Admin', VENDOR_ADMIN]
  ]

  LOCATION = [
    ['Location Exec', LOCATION_EXEC], 
    ['Location Admin', LOCATION_ADMIN],
    ['Location Delivery Staff', LOCATION_DELIVERY_STAFF],
    ['Location Server Staff', LOCATION_SERVER_STAFF]
  ]

  VENDOR_STAFF = [ VENDOR_EXEC, VENDOR_ADMIN ]
  LOCATION_STAFF = [ LOCATION_EXEC, LOCATION_ADMIN, LOCATION_DELIVERY_STAFF, LOCATION_SERVER_STAFF ]

  scope :vendor_only, where(roletype_id: VENDOR_STAFF)
  scope :location_only, where(roletype_id: LOCATION_STAFF)
  scope :active, where(active: true)

  # Public: get thre role type name.
  #
  def type
    TYPES[roletype_id]
  end
end

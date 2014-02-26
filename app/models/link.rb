class Link < ActiveRecord::Base
  belongs_to :linkable, :polymorphic => true

  #validates :value, :url => { :allow_nil => true, :allow_blank => true }
  
  VENDOR_NAMES = ['Main Website URL', 'Facebook Page', 'Twitter URL']

  LOCATION_NAMES = ['Google Places', 'Yelp', 'Foursquare', 'Urbanspoon']
  OPTIONAL_NAMES = ['Review', 'Article', 'Other']

end

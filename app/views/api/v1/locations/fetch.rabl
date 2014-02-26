collection @locations => :locations

attributes :id, :description, :phone, :dine_in, :take_out, 
  :address_delivery, :spot_delivery, :integrate_pos, :tax_rate,
  :delivery_fee, :delivery_minimum, :time_offset

node :delivery_via_spot do |l|
  l.delivery_via_spot || false
end

node :delivery_via_contractor do |l|
  l.delivery_via_contractor || false
end

child :address do
  attributes :street1, :street2, :city, :state, :zip, :lat, :lng
end

child :vendor do
  attributes :id, :name, :website, :legal_name, :description

  node :image_url do |vendor|
    request.base_url + vendor.logo_image.thumb('90x90#').url if vendor.logo_image.present?
  end
end

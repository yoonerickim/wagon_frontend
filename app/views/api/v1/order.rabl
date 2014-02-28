object @order

attributes :id, :state, :pay_state, :delivery_instructions, :custom_total, :order_type, :tip, :location_name, :custom_order_body, :approx_cost, :actual_cost, :use_customer_geometry, :submitted_at

node :order_items do |order|
    order.order_items.map{|item| item.body }
end
child :saved_card do
    attributes :id, :card_type, :last_four, :expires_on, :first_name, :last_name, :street1, :street2, :city, :state, :zip
end
child :current_delivery_spot => :current_delivery_spot do
    attributes :lat, :lng
end
child :delivery_spot do
    attributes :lat, :lng, :reverse_address, :use_reverse, :street1, :street2, :city, :state, :zip
end

child :custom_location do
    attributes :lat, :lng, :reverse_address, :use_reverse, :street1, :street2, :city, :state, :zip
end

child :deliverer => :deliverer do
    child :geometry => :geometry do
      attributes :lat, :lng
    end
end

node :receipt_image_url do |order|
    request.base_url + order.receipt_image.url if order.receipt_image.present?
end

child :user do
    attributes :first_name, :last_name, :cell_phone, :id
end

child :notes => :notes do
    attributes :message, :created_at
    node :author do |note|
        if note.author == note.order.user
            "Customer (" + note.author.first_name + ")"
        else
            "Courier (" + note.author.first_name + ")"
        end
    end
end


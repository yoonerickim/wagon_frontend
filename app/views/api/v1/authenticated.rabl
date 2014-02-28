attributes :id, :first_name, :last_name, :email, :cell_phone, :clocked_in, :should_track
node :created_date do |u|
    u.created_at
end
node :can_deliver do |u|
    u.is_delivery_contractor?
end
node :cohort do |u|
    u.cohort_id
end

child :mobile_token => :token do
    attributes :token, :expires_at
end

node :orders do |user|
  user.orders.active.map do |order|
     partial 'api/v1/order', object: order, root: false
  end
end

node :queue do |user|
  user.assigned_orders.active.map do |order|
     partial 'api/v1/order', object: order, root: false
  end
end

namespace :billing do
  namespace :couriers do
    desc "back-fill order reimbursements and delivery fees."
    task :backfill => :environment do
      for order in Order.where(state: ['fulfilled', 'undeliverable']).all        
        if !BillingActivity.find_by_order_id(order.id)          
          o = BillingActivity.create(:order_id => order.id, :user_id => order.assigned_to.id, :description => "Courier Fee for Order ##{order.id}", :amount => order.courier_fee_in_cents)
          o.created_at = order.fulfilled_at
          o.created_at = order.undeliverable_at if order.fulfilled_at.blank? 
          o.save
          o = BillingActivity.create(:order_id => order.id, :user_id => order.assigned_to.id, :description => "Reimbursement for Order ##{order.id} (#{order.location_name})", :amount => order.actual_cost)          
          o.created_at = order.fulfilled_at
          o.created_at = order.undeliverable_at if order.fulfilled_at.blank? 
          o.save          
        end
      end
    end
  end # end orders ns
end

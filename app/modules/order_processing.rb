module OrderProcessing

  def preorder_check
    @available_contractors = User.all_available_contractors_containing(@pin_coordinates, @location_coordinates) rescue nil
  end 

  def finish_order
    #we can get more complex here about who to assign to -- for now, it's random based on what the db returns.  
    
    if @order.present?
      if @available_contractors.present? 
        @order.assigned_to_id = Order.assign_delivery_contractor(@available_contractors) 
      else
        @order.errors.add :delivery_spot, " is not servicable at this time"
      end
    end
       
    if @available_contractors.present? and @order.save and @order.submit
        
      log_and_notify "Mailer problem on user confirmation. Order ##{@order.id}" do
        OrderMailer.user_confirmation(@order.id).deliver
      end
  
      #need to notify the delivery contractor here 
     
      log_and_notify "Mailer problem on contractor notificaiton. Order ##{@order.id}" do
        OrderNotifier.contractor_notifications(@order)
      end     

      log_and_notify "Mailer problem on admin notificaiton. Order ##{@order.id}" do
        OrderMailer.admin_notification(@order.id).deliver
      end     

      #log_and_notify "Mailer problem on location confirmation. Order ##{@order.id}" do
      #  OrderNotifier.location_notifications(@order)
      #end
      true
    else
      false
    end
  end
end

class CallsController < ApplicationController
  
  def new_call
    
    @order = Order.find(params[:order_id])
        
    render :layout => false
  end
  
  def order_details_request_from_call
  
    @order = Order.find(params[:order_id])
    
    render :layout => false
  
  end  

  def confirm_order_via_call
        
    @order = Order.find(params[:order_id])
    
    unless params[:Digits] == '5'
      render :action => 'order_details_request_from_call', :order_id => params[:order_id], :layout => false      
    else
      #confirm the order here
      if @order.confirm
        @good_to_go = true
      end
      render :layout => false
    end
    #make it blank for now 
  end
  
end

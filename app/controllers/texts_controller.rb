class TextsController < ApplicationController

  respond_to :xml

  def smsreply
    
    if params[:From].present? and params[:Body].present? and @user = User.find_by_cell_phone(params[:From].gsub("+1",''))
    
      @num = ["submitted", "confirmed", "on_delivery"].index(@user.orders.last.state) rescue nil 
    
      if @num.present? 
        @order = @user.orders.last
        OrderNote.create(:message => params[:Body], :order_id => @order.id, :author_id => @order.assigned_to.id) rescue nil 
        @body = "Your message was sucessfully posted to order ##{@order.id} and received by the courier."  
      else
        @body = "Sorry, your message was not received. If you'd like to contact us, please message us through the app or email info@hitthespot.com. Thanks."
      end
  
    else
      @body = "Sorry, your message was not received. Please reply within your order messages in the Hit The Spot app (or website)."     
    end

    render :layout => false

  end

end
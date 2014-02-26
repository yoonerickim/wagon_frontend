class Dashboard::OrdersController < ApplicationController
  before_filter :find_order
  filter_access_to :all, attribute_check: true
  respond_to :js

  def show; end

  # Public: Edit an order
  #
  # Use this if the location needs to edit the order.
  #
  def edit; end

  # Public: Update an order.
  #
  # Use this for if the location has to update teh order.
  #
  def update;  end

  # Public: AJAX action to get order status update.
  #
  def status; end

  # Start order process actions #
  #
  
  # Public: Assign an employee to the order.
  #
  def assign
    @order.assigned_to_id = params[:order][:assigned_to_id]
    @order.reload if @order.save
    render 'status'
  end

  def confirm_dialog
    render formats: [:html], layout: false
  end

  # Public: Confirm and order after it has been submitted.
  #
  def confirm
    @order.confirm_notes = params[:order][:confirm_notes]
    @order.approx_cost = (@order.approx_cost.to_f * 100.0).floor
    @order.confirm
    
    if @order.confirm_notes.present? 
      OrderNote.create(:message => @order.confirm_notes, :order_id => @order.id, :author_id => @order.assigned_to.id) rescue nil 
    end

    @order.approx_cost = (@order.approx_cost.to_f / 100.0).floor
    
    render 'status'
  end

  # Public: Cancel and order if possible.
  #
  def cancel
    @order.cancel_by_location
    render 'status'
  end

  # Public: Mark an order to out for delivery.
  #
  def deliver
    
    
    params[:order][:actual_cost] = (params[:order][:actual_cost].to_f * 100.00).floor rescue nil 
    #params[:order][:approx_cost] = (params[:order][:approx_cost].to_f * 100.00).floor rescue nil 
     
    @order.approx_cost = (@order.approx_cost.to_f * 100.0).floor
    
    @upper_amount_in_cents = (@order.approx_cost.to_f * 1.35)
    
    #here is where you should 
    if params[:order][:actual_cost].present? && params[:order][:receipt_image].present? && @upper_amount_in_cents >= params[:order][:actual_cost] && @order.update_attributes(params[:order]) && @order.deliver 
      render 'status'
    else
      respond_to do |format|
        format.js
      end      
             
    end
  
  end

  # Public: Mark an order as un able to be delivered.
  #
  def undeliverable
    @order.undeliverable
    render 'status'
  end

  # Public: Mark an order as complete.
  #
  def fulfill
    @order.approx_cost = (@order.approx_cost.to_f * 100.0).floor
    @order.fulfill
    render 'status'
  end

  #
  # End order process actions #

  # Start payment process actions #
  #

  def reauthorize
    @order.reauthorize
  end

  # Public: Void an order.
  #
  # Available before capture.
  #
  def void
    @order.void_payment
    render 'status'
  end

  # Public: Capture payment.
  #
  def capture
    @order.capture_payment
    render 'status'
  end

  # Public: Refund an order.
  #
  # Required after captured or settled.
  #
  def refund
    @order.refund_payment
    render 'status'
  end

  # 
  # End payment process actions #
  
  # Start user actions #
  #
  
  def user_cancel
    @order.cancel_by_user
    render 'user'
  end

  def user_edit; end

  def user_update 
    @order = Order.find(params[:order_id])
    params[:order][:approx_cost] = (params[:order][:approx_cost].to_f * 100.00).floor
    if @order.present? and @order.update_attributes(params[:order])
      @good_to_go = true
      
    else
      @order.approx_cost = @order.approx_cost.to_f / 100.00
      
    end
   
  end

  def user_message; end
  
  def user_message_send
    @order_note = OrderNote.new(params[:order_note])
    @order_note.author_id = current_user.id
    @order_note.save
    @order = @order_note.order
  end

  def user_destroy
    @order.destroy if @order.present?
  end

  def tip
    @order.tip = params[:order][:tip]

    if @order.valid? && @order.capture_with_tip
      flash.now[:notice] = "Thanks for your tip and order!"
    else
      # failed
    end
  end

  # 
  # End user actions #

  private

  def find_order
    id = params[:id]

    # Use order_id if present and id is missing,
    #
    id = params[:order_id] if id.blank? && params[:order_id].present?
    @order = Order.find(id)
    @order.approx_cost = @order.approx_cost.to_f / 100.00
  end

end

class OrdersController < ApplicationController
  include OrderProcessing
  force_ssl
  respond_to :js, only: [:logged_in]

  before_filter :find_placed_order, only: [:checkout, :edit, :update, :submit, :logged_in]
  before_filter :check_available_contractors, only: [:custom_order_checkout, :custom_order_submit]
  # Called when place order is pressed on menu overlay.
  #
  def place
    order = Order.find(params[:id])

    order.update_attributes(user_id: current_user.id) if current_user.present?
    order.build_delivery_spot unless order.delivery_spot.present?

    # Sanitize and set delivery_spot location.
    {pin_lat: :lat, pin_lng: :lng, pin_address: :reverse_address}.each do |k,v|
      order.delivery_spot.send :"#{v}=", session[k]
    end

    # Might want to set the state to placed here. So we can change button
    # on Checkout Menu Overlay to Update Order or similar also to render
    # a JS view to preserve their changes to payment, etc.
    #
    order.delivery_spot.save

    session[:placed_order] = order.id
    redirect_to checkout_order_path
  end

  # Public: 
  #
  def logged_in
    find_cards # if logged in
  end

  # Public: Action when "Edit Order" link is clicked on checkout
  # page.
  #
  def edit; end

  # Public: Action called from update menu overlay on checkout.
  #
  def update; end

  # The checkout form.
  #
  def checkout
    if current_user && current_user.kind_of?(LiveLocationUser)
      redirect_to dashboard_live_url(protocol: https)
      return
    end
    @new_user = @order.build_user unless @order.user
    @order.build_saved_card
    find_cards
  end
  
  def custom_order_checkout
    logger.debug @available_contractors.inspect
    if @available_contractors.blank?
      flash[:notice] = "Sorry - deliveries are not available from that location at this time."
      redirect_to '/confirm_location?a=' + URI.escape(params[:pin_address]) + '&lat=' + params[:pin_lat] + '&lng=' + params[:pin_lng]      
    else     
      if current_user && current_user.kind_of?(LiveLocationUser)
        redirect_to dashboard_live_url(protocol: https)
        return
      end
      @order = Order.new
      @new_user = @order.build_user
      @order.build_saved_card
      find_cards    
    end  
  end
  
  
  def custom_order_submit

      if current_user.present?
        user = current_user
        params[:order].delete(:new_user)
      else
        [:first_name, :last_name].each do |key|
          params[:order][:new_user][key] = params[:order][:saved_card_attributes][key]
        end
        @new_user = User.find_or_create_by_email(params[:order].delete(:new_user))
        user = @new_user
      end    

      if params[:order].fetch(:saved_card_id, 'new') == 'new'
        params[:order].delete(:saved_card_id)
        params[:order][:saved_card_attributes].merge!(user_id: user.id)
      else
        params[:order].delete(:saved_card_attributes)
      end

      if session[:order_id].present? 
        @order = Order.find(session[:order_id])
        @order.update_attributes(params[:order])
      else
        @order = Order.new 
        @order.attributes = params[:order] 
        @order.user = user
      end
    
      @order.build_delivery_spot 
      @order.delivery_spot.lat = params[:pin_lat]
      @order.delivery_spot.lng = params[:pin_lng]
      @order.delivery_spot.reverse_address = params[:pin_address]

      @order.build_custom_location
      @order.custom_location.lat = params[:location_lat]
      @order.custom_location.lng = params[:location_lng]
      @order.custom_location.nickname = @order.location_name
       
      @order.approx_cost = (@order.approx_cost.to_f * 100.00).floor if @order.approx_cost.present? 
       
      if finish_order
        session[:order_id] = nil 
                redirect_to order_thank_you_path, :notice => "Your order was successful!"
      else
        logger.debug @order.errors.inspect

        @new_user = @order.build_user unless @order.user
        @order.build_saved_card unless @order.saved_card.present?
        find_cards
        session[:order_id] = @order.id if @order.id.present? 

        @order.approx_cost = (@order.approx_cost.to_f / 100.00)

        if @avilable_contractors.blank?
          flash[:notice] = "Sorry - deliveries are no longer available for this order at this time."
        end

        render 'custom_order_checkout'
      end
    
  end
  

  # Checkout submit action.
  #
  def submit

    if current_user.present?
      user = current_user
      params[:order].delete(:new_user)
    else
      [:first_name, :last_name].each do |key|
        params[:order][:new_user][key] = params[:order][:saved_card_attributes][key]
      end
      @new_user = User.find_or_create_by_email(params[:order].delete(:new_user))
      user = @new_user
    end

    if params[:order].fetch(:saved_card_id, 'new') == 'new'
      params[:order].delete(:saved_card_id)
      params[:order][:saved_card_attributes].merge!(user_id: user.id)
    else
      params[:order].delete(:saved_card_attributes)
    end

    @order.attributes = params[:order].merge(user_id: user.id) # must last before submit!
    @order.set_contractor_delivery

    if @order.submit
      session.delete(:placed_order)
      session[:orders].delete(@order.location.id.to_s)

      log_and_notify "Mailer problem on user confirmation. Order ##{@order.id}" do
        OrderMailer.user_confirmation(@order).deliver
      end
      log_and_notify "Mailer problem on location confirmation. Order ##{@order.id}" do
        OrderNotifier.location_notifications(@order)
      end

      redirect_to order_thank_you_path, :notice => "Your order was successful!"
    else
      logger.debug @order.errors.inspect

      @new_user = @order.build_user unless @order.user
      @order.build_saved_card unless @order.saved_card.present?
      find_cards

      render 'checkout'
    end
  end

  # Public: Redirection after successful order
  #
  def thank_you; end

  private

  # Private: Find the current placed order.
  #
  def find_placed_order
    @order = Order.find(placed_order)
    unless @order.pending?
      session.delete(:placed_order)
      session[:orders].delete(@order.location.id.to_s)
      raise ActiveRecord::RecordNotFound.new("Already submitted") if @order.submitted?
    end
  end

  # Private: Find cards for current user.
  #
  def find_cards
    if current_user.present? && current_user.saved_cards.size > 0
      @saved_cards = current_user.saved_cards 
      @default_card = current_user.saved_cards.order('id DESC').first
    end
  end
 
  def check_available_contractors    
    @pin_coordinates = [params[:pin_lat].to_f, params[:pin_lng].to_f]
    @location_coordinates = [params[:location_lat].to_f, params[:location_lng].to_f]
    preorder_check
  end
end

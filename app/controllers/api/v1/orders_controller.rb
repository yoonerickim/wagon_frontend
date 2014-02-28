class Api::V1::OrdersController < Api::V1::ApiController
  include OrderProcessing

  before_filter :find_order, only: [:status, :show, :capture, :update, :cancel_by_user, :message]
  before_filter :find_customer_order, only: [:track_user]
  before_filter :find_deliverer_order, only: [:fulfill, :undeliverable, :cancel_by_location, :confirm, :picked_up]
  before_filter :check_available_contractors, only: [:submit]

  before_filter :tweak_order_parameter, only: [:submit, :update]

  # Public: Build and Place an order.
  #
  # params:
  # token - the valid user token.
  #
  # order[:location_id]
  # order[:saved_card_id]
  # order[:tip]: 0-100% as an integer, defaults to 15%
  # order[:terms]: 0/1 or false/true
  #
  # order[:line_items_attributes]:
  # quantity
  # menu_item_id
  # menu_size_id
  # special_instructions
  #
  # order[:line_items_attributes][options_attributes]:
  # quantity
  # menu_option_item_id
  #
  # 
  # order[:delivery_spot_attributes]
  # lat
  # lng
  # reverse_address
  # use_reverse (defaults true)
  # street1, street2, city, state, zip
  #
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA", "order":{"location_id":1, "saved_card_id":1, "tip":20, "terms":1, "order_type":"1", "delivery_spot_attributes":{"lat": 0.0, "lng": 0.11, "reverse_address": "123 Blah St., WA, 98101, USA"}, "line_items_attributes":{"0":{"quantity":3, "menu_item_id":1}}}}' http://localhost:8080/api/v1/orders/submit
  #
  # Returns created/submitted order.
  def submit
    requires! params, :token, :order
    requires! params[:order], :saved_card_id, :terms, :delivery_spot_attributes


    @order = @token.user.orders.build(params[:order])

    if finish_order.blank?
      json_errors @order.errors.full_messages
    else
      render 'submit'
    end
  end

  def update
    
    requires! params, :token, :order
    requires! params[:order], :saved_card_id, :terms, :delivery_spot_attributes
    if @order.state == 'submitted' or @order.state == 'confirmed'
        
        if params[:order][:order_items_attributes].present?
            @order.order_items.clear
        end
        @order.attributes = params[:order]

        

        if @order.save
          render 'submit'
        else
          json_errors @order.errors.full_messages
        end
    else
        json_errors ['Order cannot be modified']
    end
  end

  # Public: Capture an order, optionally with a tip
  #
  # params:
  # token
  # tip - percentage in an integer or string. 50 = 50%
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA", "tip":50}' http://localhost:8080/api/v1/orders/6/capture
  #
  def capture
    requires! params, :token, :order
    @order.capture_with_tip(params[:tip])
    render 'show'
  end

  def confirm
    requires! params, :token, :order, :note

    @order.confirm_notes = params[:note]
    @order.confirm
    
    if @order.confirm_notes.present? 
      OrderNote.create(:message => @order.confirm_notes, :order_id => @order.id, :author_id => @order.assigned_to.id) rescue nil 
    end
      
    render 'show'
  end

  def picked_up
    requires! params, :token, :order, :image, :actual_cost

    @order.actual_cost = params[:actual_cost];
    @order.receipt_image = Base64.decode64(params[:image])
    @order.deliver
    render   'show'
  end
  # Public: Get the status and pay status of a user's order or
  # an order assigned to this user.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA"}' http://localhost:8080/api/v1/orders/6/status
  #
  # Returns order only with id, state, and pay_state.
  def status
    requires! params, :token
    render 'show'
  end

  def track_user
    requires! params, :token
    if params.has_key?(:lat) and params.has_key?(:lng) 
      @token.user.set_geometry(params[:lat].to_f, params[:lng].to_f)
      @order.use_customer_geometry = true
    else
      @order.use_customer_geometry = false
    end
    @order.save!      
    render 'show'
  end


  # Public: Get the details for an order.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA"}' http://localhost:8080/api/v1/orders/6
  #
  # Return the order.
  def show
    requires! params, :token
  end

  # Public: 
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA"}' http://localhost:8080/api/v1/orders/6/fulfill
  #
  #
  def fulfill
    requires! params, :token, :order
    @order.fulfill
    render   'show'
  end

  # Public: 
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA"}' http://localhost:8080/api/v1/orders/6/undeliverable
  #
  #
  def undeliverable
    requires! params, :token, :order
    @order.undeliverable
    render   'show'
  end

  # Public: 
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"Fi4WNIMQe537_uAHXwiBvFnxz4iAyphpaWoNfNCfI2u46N27NiVbTl0deoLi1s5vXOIRackgWwiymi5o5T6ziA"}' http://localhost:8080/api/v1/orders/6/cancel_by_location
  #
  #
  def cancel_by_location
    requires! params, :token, :order
    if @order.cancel_by_location
      render 'show'
    else
      json_errors @order.errors.full_messages
    end
  end

  def cancel_by_user
    requires! params, :token, :order
    @order.cancel_by_user
    render 'show'
  end

  def assign
    requires! params, :token, :user_id

    if @token.user.super_user?
      @order = Order.find(params[:id])
      @order.assigned_to = User.find(params[:user_id])
      if @order.save
        render nothing: true, status: 200
      else
        json_errors @order.errors.full_messages
      end
    else
       render nothing: true, status: 401
    end
  end

  def message
    requires! params, :token, :message

    OrderNote.create(message: params[:message], 
        order_id: @order.id, author_id: @token.user.id)
    render 'submit'
  end

  private

  # Private: Find an order accessible by either by the customer or deliverer
  #
  def find_order
    @order = Order.where("assigned_to_id = ? OR user_id = ?", @token.user.id, @token.user.id).find(params[:id])
  end


  # Private: Find an order accessible by the deliverer
  #
  def find_deliverer_order
    @order = @token.user.assigned_orders.find(params[:id])
  end

  def find_customer_order
    @order = @token.user.orders.find(params[:id])
  end

  def check_available_contractors    
      @pin_coordinates = [params[:order][:delivery_spot_attributes][:lat], params[:order][:delivery_spot_attributes][:lng]]
      @location_coordinates = [params[:order][:custom_location_attributes][:lat], params[:order][:custom_location_attributes][:lng]]
      preorder_check
  end

  def tweak_order_parameter 
    if not params[:order][:order_items].blank?
      params[:order][:custom_order_body] = params[:order][:order_items].join("\n")
      params[:order][:order_items_attributes] = params[:order][:order_items].map{ |item| {:body => item} }
      params[:order].delete(:order_items)
    end
  end
end

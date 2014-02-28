class LocationsController < ApplicationController
  respond_to :js

  # Display AJAX menu overlay
  #
  def menus
    @order = Order.find_by_id(params[:order_id]) if params[:order_id].present?
    @order ||= order_for(params[:id], params[:type])

    @location = Location.includes(:menus => {:groups => :items}).find(params[:id])
    @item = @location.menu_items.find_by_id(params[:menu_item_id])
  end

  # Display AJAX fetch locations
  #
  def fetch
    @delivery_type = params[:t]
    @coordinates = [params[:lat].to_f, params[:lng].to_f]
    @q = params[:q]
    
    # Default to Spot Delivery
    #
    @delivery_type ||= Order::SPOT_DELIVERY

    # Delivery should return Spot, Address, and Takeout (Takeout only of contractor
    # option selected by location.)
    #
    if [Order::SPOT_DELIVERY, Order::ADDRESS_DELIVERY].include? @delivery_type
      types = [Order::SPOT_DELIVERY, Order::ADDRESS_DELIVERY, Order::CUSTOM, Order::CONTRACTOR]
    else
      types = @delivery_type
    end

    @locations = Location.includes(:vendor).close_to(@coordinates, within: 50).
      applicable(types).search(@q)

    if [Order::SPOT_DELIVERY, Order::ADDRESS_DELIVERY].include? @delivery_type
      # Reject locations htat cannot deliver to the coordinates either by internal
      # or contractor delivery
      #
      @locations.reject! { |location| !location.can_deliver?(to: @coordinates) }

      # Extract locations that can do spot deliveries
      #
      spot_locations, locations = @locations.partition { |location| location.delivery_via_spot }

      # Extract contract delivery only locations.
      #
      contractor_locations, locations = locations.partition { |location| location.delivery_via_contractor }

      # Sort by distance.
      #
      spot_locations.sort_by! { |location| location.distance(@coordinates) }
      contractor_locations.sort_by! { |location| location.distance(@coordinates) }
      locations.sort_by! { |location| location.distance(@coordinates) }

      @locations = spot_locations + contractor_locations + locations
    else
      @locations.sort_by! { |location| location.distance(@coordinates) }
    end
  end
  
end

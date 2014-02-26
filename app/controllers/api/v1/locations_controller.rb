class Api::V1::LocationsController < Api::V1::ApiController

  skip_before_filter :find_and_check_token_validity

  # Fetch locations in bounds
  #
  # params
  # lat
  # lng
  # type: POT_DELIVERY = '1', ADDRESS_DELIVERY = '2',TAKE_OUT = '3', DINE_IN = '4'
  # q - search term
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"lat":"47.606", "lng":"-122.332", "type":"1"}' http://localhost:8080/api/v1/locations/fetch
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" \
  #   -X GET "http://localhost:8080/api/v1/locations/fetch?lat=47.606&lng=-122.332&type=1"
  #
  # TODO: Change t to type!
  #
  def fetch
    requires! params, :lat, :lng, :t

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
      types = [Order::SPOT_DELIVERY, Order::ADDRESS_DELIVERY, Order::CONTRACTOR, Order::CUSTOM]
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

  # Get menus for a location.
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET http://localhost:8080/api/v1/locations/1/menus
  # 
  def menus
    @menus = Menu.where(location_id: params[:id]).all
  end

  def lookup_by_google_id
    requires! params, :id
    @vendor = Gvendor.find_by_gid(params[:id])
  end

  def contractors_available
    requires! params, :lat, :lng
    if params[:location_lat].present?
      requires! params, :location_lat, :location_lng
      pin_coordinates = [params[:lat].to_f, params[:lng].to_f]
      location_coordinates = [params[:location_lat].to_f, params[:location_lng].to_f]
      contractors = User.all_available_contractors_containing(pin_coordinates, location_coordinates) rescue nil
      if contractors.present?
        render nothing: true, status: 202
      else
        render nothing: true, status: 406
      end
    else
      @coordinates = {:lat => params[:lat], :lng => params[:lng]}
      if User.contractors_available?(@coordinates) 
        render nothing: true, status: 202
      else
        render nothing: true, status: 406
      end
    end
  end

  def polygon_available
    @polygons = User.active_and_clocked_in_couriers.all.find_all{|user| user.delivery_boundaries.present?}
  end
end

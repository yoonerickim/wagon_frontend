class ApplicationController < ActionController::Base

  if Rails.env.production? 
    force_ssl except: [:mobile_about, :terms, :new_call, :order_details_request_from_call, :confirm_order_via_call, :send_mobile_feedback, :smsreply]  
  end
  
  protect_from_forgery
  before_filter { |c| Authorization.current_user = c.send(:current_user) }

  helper_method :current_user, :current_user!, :live_location

  # Catch when a user is not logged in.
  #
  rescue_from User::RecordNotFound do
    redirect_to login_path, :alert => "Please log in to view your account."
  end

  # Catch when a non-existent record is requested.
  #
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, :alert => "It appears what you are looking for does not exist."
  end
  
  # Catch when a user fails to view live location.
  #
  rescue_from User::UnauthorizedLiveLocation do
    redirect_to login_path, :alert => "Please log in to view your live location dashboard."
  end

  # Catch if a url is not listed in routes.
  #
  rescue_from ActionController::RoutingError do
    redirect_to root_path, :alert => "Page not found."
  end

  # Public: Called by declarative authorization if permission is denied
  # for an action.
  #
  def permission_denied
    #flash.alert = "Sorry! You are not allowed on that page."
    if current_user.present? && current_user.kind_of?(User)
      redirect_to dashboard_account_path
    else
      session[:unauthorized_url] = request.url
      redirect_to login_path
    end
  end

  before_filter :httpauth
  
  # I think this can be replaced with something along the lines of:
  #
  # http_basic_authenticate_with :name => "preview", :password => "hitthespot"
  #
  def httpauth
    #password protection on live site until we launch 
    unless Rails.env.development? || Rails.env.test? || Rails.env.production?
      if !request.env['REQUEST_URI'].index(/vendor/i) && !request.env['REQUEST_URI'].index(/api/i) && !request.env['REQUEST_URI'].index(/mobile-about/i) && !request.env['REQUEST_URI'].index(/terms/i) && !request.env['REQUEST_URI'].index(/calls/i) && !request.env['REQUEST_URI'].index(/send_mobile_feedback/i)
        authenticate_or_request_with_http_basic do |user_name, password|
          user_name == 'preview' && password == 'hitthespot'
        end
      end
    end
  end

  # Public: Return the correct protocol for the envronment.
  #
  # Redirection from the server should be the full path. Specify this method for
  # protocol when you want https and it will smartly give it based on the
  # environment.
  #
  # If you want http, then specify 'http'. This is only for https, when possible.
  # 
  # Returns a string: 'http' or 'https'
  def https
    @https ||= [:production].include? Rails.env.to_sym ? 'https' : 'http'
  end
  helper_method :https

  private

  # Public: Get the current logged in user. May be used in controllers and
  # views
  #
  # Example:
  #   current_user
  #
  # Returns the current user object.
  def current_user
    @current_user ||= session_user
  end

  # Public: Get the current logged in user, but throws User::RecordNotFound
  # if the usere is not available.
  #
  # Example:
  #   begin
  #     current_user!
  #   rescue User::RecordNotFound
  #     # do something
  #   end
  #
  # Returns the current user object.
  def current_user!
    raise User::RecordNotFound unless current_user
    current_user
  end

  # Private: Get the user stored in the session. Does not memoize.
  # Use current_user or current_user! if possible, as they protect
  # access to the user object in Live Location Dashboard mode.
  #
  def session_user
    case
    when session[:user_id].present?
      User.find_by_id(session[:user_id])
    when live_location.present?
      LiveLocationUser.new(live_location)
    end
  end

  # Public: Set a live location. Throws an exception if
  # not authorized.
  #
  def live_location=(location)
    if current_user && location
      @current_user = nil # no more access to user
      session.delete :user_id
      session[:live_location_id] = location.id
    else
      raise User::UnauthorizedLiveLocation
    end
  end

  # Public: Get the live location if there is one.
  #
  def live_location
    @live_location ||= Location.find(session[:live_location_id]) if session[:live_location_id]
  end

  # Public: Remove live location.
  def clear_live_location!
    session.delete(:live_location_id)
    @live_location = nil
  end
  
  # Public: Get the current order for a location, or create one if it
  # does not exist already.
  #
  # location_id - the id for the location
  #
  # Returns the an order instance.
  def order_for(location_id, order_type=nil)
    order = Order.find(orders[location_id.to_s])
    raise ActiveRecord::RecordNotFound.new "Order not pending." unless order.pending?
    order
  rescue ActiveRecord::RecordNotFound
    session.delete(:placed_order)
    attributes = { location_id: location_id }
    attributes.merge! order_type: order_type if order_type
    #attributes.merge! user_id: current_user.id if current_user # better to just set at checkout
    order = Order.create(attributes)
    orders[location_id.to_s] = order.id
    order
  end
  helper_method :order_for

  # Public: Get orders hash stored in session.
  # 
  # The session hash is defined below. Assume all keys/values are strings.
  # session[:orders] = { "location_id" => "order_id" }
  #
  def orders
    orders = session[:orders].nil? ? session[:orders] = {} : session[:orders]
    orders
  end

  # Public: Get the placed order. This is assigned to the session when a place
  # order button is pressed. If a user goes back to the map and hits that place
  # order button, then that order becomes the placed order.
  #
  def placed_order
    @placed_order ||= Order.find_by_id(session[:placed_order]) if session[:placed_order]
  end
  helper_method :placed_order

  # Public: Same as placed order but raises if nil.
  #
  def placed_order!
    raise Order::RecordNotFound unless current_order
  end
  helper_method :placed_order!
  
end

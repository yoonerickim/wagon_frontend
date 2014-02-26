class Api::V1::UsersController < Api::V1::ApiController

  skip_before_filter :find_and_check_token_validity, only: [:create, :authenticate]

  # Public: Create a user.
  #
  # params:
  # device_uid
  # version_uid
  # user[first_name]
  # user[last_name]
  # user[email]
  # user[password]
  # user[password_confirmation]
  # user[cell_phone] - optional
  #
  # Examples: 
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"device_uid":"123", "version_uid":"current", "user":{"first_name":"First", "last_name": "Last", "email":"first@first.com", "password":"password", "password_confirmation":"password"}}' http://localhost:8080/api/v1/user
  #
  # Returns user and token.
  def create
    requires! params, :device_uid, :version_uid
    requires! params[:user], :first_name, :last_name, :email, :password

    token = MobileToken.new(device_uid: params[:device_uid], version_uid: params[:version_uid])
    if token.valid?
      user = token.build_user(params[:user])
      if user.save && token.save
        @user = user
        render 'show', status: 201
      else
        @errors = user.errors.full_messages
        render 'errors', status: 400
      end
    else
      raise UnauthorizedError.new "device_uid or version_uid not appropriate"
    end
  end

  # Public: Authenticate a user.
  #
  # Example:
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST \
  #   -d '{"username":"foo@foo.com", "password":"password", "device_uid":"1234abcd", \
  #   "version_uid":"v1_dj&/72hs5A"}' http://localhost:8081/api/v1/user/authenticate
  #
  # NOTE: Until we scheme version constants, make sure version_uid contains 'current'. As
  # seen below:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"username":"foo@foo.com", "password":"password", "device_uid":"1234abcd", "version_uid":"v1current_dj&/72hs5A"}' http://localhost:8081/api/v1/user/authenticate
  #
  # Returns the created token, containing the token string, expiration.
  def authenticate
    requires! params, :username, :password, :device_uid, :version_uid 
    raise ArgumentError.new "Username must be present" if params[:username].blank?
    params[:username] = params[:username].downcase

    if params[:username] =~ /@/
      user = User.find_by_email(params[:username]) || User.find_by_cell_phone(params[:username])
    else
      user = User.find_by_cell_phone(params[:username]) || User.find_by_email(params[:username])
    end

    if user && user.authenticate(params[:password])
      if user.set_mobile_token(device_uid: params[:device_uid], version_uid: params[:version_uid])
        @user = user
        render 'show'
      else
        @errors = user.mobile_token.errors.full_messages
        render 'errors', status: 400
      end
    else
      raise UnauthorizedError.new "User (id: #{user.try(:id)}) could not be authenticated."
    end
  end

  # Public: Refresh an unexpired token.
  #
  # Examples:
  #
  # NOTE: Replace with a current token.
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"GxYAl2pu-ly_PjUj8wLUmqF2h7A28NGJSVWdAzwYpj3vDdjLKw12jSChQFPkFVNAVuzcVGYcU_DjKvIZ3OB0jQ"}' http://localhost:8080/api/v1/user/refresh
  # 
  # Returns the created token, same as authenticate.
  def refresh
    requires! params, :token

    unless @token.refresh
      @errors = @token.errors
      render 'errors', status: 400
    else
      render 'token'
    end

  end

  def clocked_in
      requires! params, :token, :clocked_in
      @token.user.clocked_in = params[:clocked_in];
      @token.user.save!
      @user = @token.user
      render 'show' 
  end

  # Public: Terminate a user's token.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST \
  #   -d '{"token":"ecHIXD4rX33kkFK_9ZP0my8xP7VvXGkG9U-0AHJXSdB4j8fc7lcI6JZpr3ngil3W5dWDA1pUukkejLRrncNYtQ"}' \
  #   http://localhost:8081/api/v1/user/terminate
  #
  # Returns status code 202: Accepted.
  def terminate
    requires! params, :token

    @token.delete
    render nothing: true, status: 202
  end

  # Public: Get a users spots.
  #
  # Examples:
  # 
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET \
  #   "http://localhost:8081/api/v1/user/spots?token=tPc2c18NReFUL59vOTdfST7F4se_b-6Eqn8yv5MiJ3HcPJ1XTo192RbZ19bHABqLG6-4ZhqdCzyiLZUeXFE49w"
  #
  # Returns an array of spots.
  def spots
    requires! params, :token
  end

  # Public: Get a users saved cards.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET \
  #   "http://localhost:8080/api/v1/user/saved_cards?token=hcP0Yn01unS981CfMfXWkFUMJG4DdbAb6KbkoE25oiSwAH_2HrW-bBjSRonve7dten4YBwcRQl9ciX96sozypA"
  #
  # Returns an array of spots.
  def saved_cards
    requires! params, :token
  end

  # Public: Set current location.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"GxYAl2pu-ly_PjUj8wLUmqF2h7A28NGJSVWdAzwYpj3vDdjLKw12jSChQFPkFVNAVuzcVGYcU_DjKvIZ3OB0jQ", "lat":"47.606", "lng":"-122.332"}' http://localhost:8080/api/v1/user/geometry
  #
  # Returns nothing/202 if accepted, or 400, if bad.
  def geometry
    requires! params, :token, :lat, :lng
    if @token.user.set_geometry params[:lat], params[:lng]
      @user = @token.user
      render 'show', status: 202
    else
      render noting: true, status: 400
    end
  end

  def status
    requires! params, :token
    @user = @token.user
    render 'show'
  end

  # Public: Get orders palced by the user.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"token":"RoAtCACzf4IO_DVJljSRvlQBu8TvW-2PTgkEfBIvRLUe_j1o4UWRZZqLcBCLcaaR48cNdwNQzYVeEueqs36f_w"}' http://localhost:8080/api/v1/user/orders
  # 
  # Returns an array of order_ids
  def orders
    requires! params, :token

    @orders = @token.user.orders
  end

  # Public: Get orders palced by the user.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"token":"RoAtCACzf4IO_DVJljSRvlQBu8TvW-2PTgkEfBIvRLUe_j1o4UWRZZqLcBCLcaaR48cNdwNQzYVeEueqs36f_w"}' http://localhost:8080/api/v1/user/assigned_orders
  #
  # Returns an array of assigned_order_ids
  def assigned_orders
    requires! params, :token

    @orders = @token.user.assigned_orders.active
    render 'orders'
  end

  def contractor_orders
    requires! params, :token

    @orders = @token.user.contractor_orders
    render 'orders'
  end
end

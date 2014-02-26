class Api::V1::SpotsController < Api::V1::ApiController

  # Public: Create a spot.
  #
  # params:
  # token - the valid user token.
  # spot[nickname] - name
  #
  # spot[street1]
  # spot[street2]
  # spot[city]
  # spot[state] - 2 char
  # spot[zip]
  # 
  # spot[lat]
  # spot[lng]
  #
  # NOTE: The web app uses lat/lng or address.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST \
  #   -d '{"token":"GXJnf_HUF-pBHFbuiqEGP1ClATz3kr7mqs2QYKU38Hihs0k1k1f_H0CO-aoAqitgO1aQWCFubKB8XkOKutsoHA", \
  #   "spot":{"street1":"123 My new street", "zip":"12345", "nickname":"New one"}}' \
  #   http://localhost:8080/api/v1/spots
  #
  # Returns created spot.
  def create
    requires! params, :token, :spot

    @spot = @token.user.spots.create(params[:spot])
    json_response
  end

  # Public: Update a spot by id.
  #
  # params - same as create
  #
  # Example: curl -v -H "Accept: application/json" -H "Content-type: application/json" -X PUT \
  #   -d '{"token":"SyFLaGZWJ3d-UikId-o9IJ3bMECdzxTSSJ4XqOuuNlR6yME1p9UbgcPxbDAwPNwojAf75PgssW0nN3BUcOYv4g", \
  #   "spot":{"nickname":"My House"}}' http://localhost:8080/api/v1/spots/10
  # 
  # Returns updated spot.
  def update
    requires! params, :token, :id, :spot

    @spot = @token.user.spots.find(params[:id])
    @spot.update_attributes(params[:spot])
    json_response
  end

  # Public: Destroy a spot by id.
  #
  # params:
  # token - the valid user token
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X DELETE \
  #   -d '{"token":"SyFLaGZWJ3d-UikId-o9IJ3bMECdzxTSSJ4XqOuuNlR6yME1p9UbgcPxbDAwPNwojAf75PgssW0nN3BUcOYv4g"}' \
  #   http://localhost:8080/api/v1/spots/10
  # 
  # Returns deleted spot.
  def destroy
    requires! params, :token, :id

    @spot = @token.user.spots.find(params[:id])
    @spot.delete if @spot.present?
    json_response
  end

  private

  # Private: Render appropriate json.
  #
  def json_response
    if @spot.errors.empty?
      render 'show'
    else
      json_errors(@spot.errors.full_messages)
    end
  end

end

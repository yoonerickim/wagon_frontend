class Api::V1::VersionsController < Api::V1::ApiController

  skip_before_filter :find_and_check_token_validity

  # Public: Check mobile app is supported.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{"version_uid":"v1current_dj&/72hs5A"}' http://localhost:8081/api/v1/version/check
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X GET \
  #   "http://localhost:8081/api/v1/version/check?version_uid=v1current_dj&/72hs5A"
  #
  # Returns 202:Accepted or error message.
  def check
    requires! params, :version_uid
    
    @url = ApiVersion.url(params[:version_uid])
    render status: 202
  end

end

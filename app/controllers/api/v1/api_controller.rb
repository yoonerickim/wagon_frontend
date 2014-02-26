class Api::V1::ApiController < ActionController::Base
  
  #not requiring SSL on the api - so it will work in demo/staging.  
  #force_ssl 
  
  respond_to :json
  before_filter :find_and_check_token_validity

  rescue_from ActiveRecord::RecordNotFound do |exception|
    log_error exception
    render nothing: true, status: 404
  end

  rescue_from UnauthorizedError do |exception|
    log_error exception
    render nothing: true, status: 401
  end  
  rescue_from NoMethodError do |exception|
    log_error exception
    render nothing: true, status: 400
  end

  rescue_from ArgumentError, ActiveRecord::UnknownAttributeError do |exception|
    log_error exception
    render nothing: true, status: 400
  end

  private

  # Internal: Render json errors.
  #
  def json_errors(errors, http_status=400)
    @errors = errors
    render 'errors', status: http_status
  end

  # Internal: Log an error.
  #
  def log_error(exception)
    logger.error "#{exception.class} (#{exception.message})"
    exception.backtrace[0...5].map { |line| logger.error "  #{line}" }
    logger.error "\n"
  end

  # Internal: Specify what params are required for each action.
  #
  def requires!(hash, *params)
    params.each do |param|
      if param.is_a?(Array)
        raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)
        valid_options = param[1..-1]
        raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(:words_connector => 'or')}") unless valid_options.include?(hash[param.first])
      else
        raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
      end
    end
  end

  # Private: Find token if param present and set @token if valid.
  #
  def find_and_check_token_validity
    token = MobileToken.includes(:user).find_by_token(params[:token]) if params[:token]
    if token.present?
      # token found
      if token.current?
        # all ok
        @token = token
      else
        # expired - so delete
        token.delete
        @token = nil
        logger.info "Attempted Access with Expired Token"
        render nothing: true, status: 403 # Forbidden
      end
    else
      # not found
      @token = nil
      logger.info "Token does not exist"
      render nothing: true, status: 401 # Unauthorized
    end
  end

end

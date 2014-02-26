Hitthespot::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  config.assets.digest = true
  config.assets.compile = false
  
  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Specify the default JavaScript compressor
  config.assets.js_compressor  = :uglifier

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  config.action_controller.asset_host = "#{ENV['STAGING_CLOUDFRONT_URL']}"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  config.action_mailer.delivery_method = :amazon_ses
  config.action_mailer.default_url_options = { :host => 'staging.hitthespot.com' }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # ActiveMerchant
  config.after_initialize do    
    ActiveMerchant::Billing::Base.mode = :test
    ::GATEWAY = ActiveMerchant::Billing::UsaEpayAdvancedGateway.new(
      :login => ENV['STAGING_USA_EPAY_LOGIN'],
      :password => ENV['STAGING_USA_EPAY_PASSWORD'],
      :software_id => ENV['STAGING_USA_EPAY_SOFTWARE_ID']
    )
  end

  config.middleware.use ExceptionNotifier,
    email_prefix: "[HTS-Staging] ",
    sender_address: %{"hts-dev" <developer@hitthespot.com>},
    exception_recipients: %w{developer@hitthespot.com}

  require 'apn_on_rails'

  configatron.apn.cert = File.join(Rails.root, 'config', 'ios-push-staging.pem')
  configatron.apn.host = "gateway.push.apple.com"
end
#Rails.logger = Le.new(ENV['STAGING_LOGENTRIES_TOKEN'])


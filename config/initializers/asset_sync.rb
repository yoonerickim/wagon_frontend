AssetSync.configure do |config|
  config.fog_provider = 'AWS'
  Rails.env.production? ? fd = ENV['PRODUCTION_FOG_DIRECTORY'] : fd = ENV['STAGING_FOG_DIRECTORY']
  config.fog_directory = fd
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

  # Don't delete files from the store
  # config.existing_remote_files = "keep"
  #
  # Increase upload performance by configuring your region
  config.fog_region = 'us-west-1'
  #
  # Automatically replace files with their equivalent gzip compressed version
  config.gzip_compression = true
  #config.always_upload = ['locales/*.js','javascripts/locales/*.js']
  #
  # Use the Rails generated 'manifest.yml' file to produce the list of files to
  # upload instead of searching the assets directory.
  # config.manifest = true
  #
  # Fail silently.  Useful for environments such as Heroku
  # config.fail_silently = true
end
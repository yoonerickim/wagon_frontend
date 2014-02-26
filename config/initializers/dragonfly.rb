require 'dragonfly'

# Documents
docs = Dragonfly[:documents]
docs.configure_with(:rails)
docs.define_macro(ActiveRecord::Base, :document_accessor)

# Images
images = Dragonfly[:images]
images.configure_with(:imagemagick)
images.configure_with(:rails)
images.define_macro(ActiveRecord::Base, :image_accessor)

# S3
unless Rails.env.development? || Rails.env.test?
 
  Rails.env.production? ? bucket_name = ENV['PRODUCTION_S3_BUCKET'] : bucket_name = ENV['STAGING_S3_BUCKET']

  [docs, images].each do |app|
    app.configure do |c|
      c.datastore = Dragonfly::DataStorage::S3DataStore.new(
        :bucket_name => bucket_name,
        :access_key_id => ENV['S3_KEY'],
        :secret_access_key => ENV['S3_SECRET']
      )
    end
  end
end

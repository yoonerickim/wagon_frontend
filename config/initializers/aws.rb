
unless Rails.env.development? || Rails.env.test? 
  AWS.config(
    :access_key_id => ENV['S3_KEY'],
    :secret_access_key => ENV['S3_SECRET'])

  #this will re-route all email to developer@ for demo and staging
  if !Rails.env.production? 
    class Hook
        def self.delivering_email(message)
            @theenv = 'DEMO' if Rails.env.demo?
            @theenv = 'STAGING' if Rails.env.staging? 
            @theenv = 'PRODUCTION' if Rails.env.production? 
            message.from = 'HTS ' + @theenv + ' EMAIL <mike@labs8.com>'
            message.to  = "mike@labs8.com"
            message.cc  = nil if !message.cc.nil?
            message.bcc = nil if !message.bcc.nil?
        end
    end
    ActionMailer::Base.register_interceptor(Hook)
  end
end
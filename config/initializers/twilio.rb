require 'yaml'
if Rails.env.development? || Rails.env.test?
  config = YAML::load_file(File.open("#{Rails.root}/config/twilio.yml"))
else
  config = {}
end

if ENV['TWILIO_SID'].present? || config.present?   
  ::TWILIO = Twilio::REST::Client.new ENV['TWILIO_SID'] || config['account_sid'], 
    ENV['TWILIO_AUTH_TOKEN'] || config['auth_token']
  ::SMS_NUMBER = ENV['TWILIO_SMS_NUMBER'] || config['sms_number']
end
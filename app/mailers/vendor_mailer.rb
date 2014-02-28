class VendorMailer < ActionMailer::Base
  include Resque::Mailer
  
  #default :from => '"Hit The Spot" <do-not-reply@hitthespot.com>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.vendor_mailer.welcome.subject
  #
  def welcome(vendor_id)
    @from = '"Hit The Spot" <do-not-reply@hitthespot.com>'
    @vendor = Vendor.find(vendor_id)
    @user = vendor.users.first
    @to = '"'
    @to += @user.first_name if @user.first_name.present? 
    @to += ' ' + @user.last_name if @user.last_name.present? 
    @to += '" <' + @user.email + '>'
    
    @host = 'localhost:3000' if Rails.env.development? || Rails.env.test?
    @host = 'demo.hitthespot.com' if Rails.env.demo? 
    @host = 'staging.hitthespot.com' if Rails.env.staging? 
    @host = 'www.hitthespot.com' if Rails.env.production? 

    mail :from => @from, :to => @to, :subject => "Confirm your Hit The Spot registration"
  end
  
  def admin_notification(vendor_id)
    @from = '"Hit The Spot" <do-not-reply@hitthespot.com>'    
    @vendor = Vendor.find(vendor_id)
    @user = vendor.users.first
    @to = 'Hit The Spot Team <info@hitthespot.com>'
    if @vendor.legal_name.blank? 
      @thesub = 'New vendor initial signup'
    else
      @thesub = 'New vendor finalized signup!'
    end    
    
    mail :from => @from, :to => @to, :subject => @thesub
  end
  
end

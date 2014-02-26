class PasswordMailer < ActionMailer::Base
  #default :from => "do-not-reply@hitthespot.com"
  include Resque::Mailer
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_mailer.reset.subject
  #
  def reset(user_id)
    @from = '"Hit The Spot" <do-not-reply@hitthespot.com>'
    
    @user = User.find(user_id)
    mail :from => @from, :to => @user.email, :subject => "Hit the Spot Password Reset Requested"
  end
end

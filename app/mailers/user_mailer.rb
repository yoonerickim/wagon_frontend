class UserMailer < ActionMailer::Base
  include Resque::Mailer
  
  default :from => '"Hit The Spot" <do-not-reply@hitthespot.com>'
 
  def welcome(user_id)
    @from = '"Hit The Spot" <do-not-reply@hitthespot.com>'
    @subject = 'Welcome to Hit The Spot!'
    @user = User.find(user_id)
    mail to: @user.email, subject: @subject
  end

  # Public: NotifyConfirm an order.
  #
  def notify_confirmed(order_id)
    @order = Order.find(order_id)
    subject = "Order ##{order_id} confirmed and in process"
    mail to: @order.user.email, subject: subject
  end

  def notify_cancelled(order_id)
    
  end

  def note_notification(order_note_id)
    @order_note = OrderNote.find(order_note_id)
    @order = @order_note.order
    subject = "A message regarding Order ##{@order.id}"
    
    if @order.assigned_to != @order_note.author
      @going_to_courier = true
      @the_to_email = @order.assigned_to.email
    else
      @the_to_email = @order.user.email      
    end
    
    mail to: @the_to_email, subject: subject
  end
  
  def generic_message(the_to, the_subject, body)
    @body = body
    subject = the_subject
  
    mail to: the_to, subject: subject, from: '"Hit The Spot" <info@hitthespot.com>'
  end
  

end

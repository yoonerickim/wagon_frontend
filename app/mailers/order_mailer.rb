class OrderMailer < ActionMailer::Base
  #default from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
  include Resque::Mailer
  
  # On submit notification
  #
  def user_confirmation(order_id)
    @order = Order.find(order_id)
    mail to: @order.user.email, subject: "Order ##{order_id}", from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
  end

  # On submit notification
  #
  def location_notification(order_id)
    @order = Order.find(order_id)
    mail to: @order.location.notify_email, subject: "New Hit The Spot Order ##{@order.id}: #{@order.user.name}", from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
  end
  
  def contractor_notification(order_id)
    @order = Order.find(order_id)
    mail to: @order.assigned_to.email, subject: "New Hit The Spot Order ##{@order.id}: #{@order.user.name}", from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
  end  
  
  def admin_notification(order_id)
    @order = Order.find(order_id)
    mail to: "info@hitthespot.com", subject: "New Hit The Spot Order ##{@order.id}: #{@order.user.name}", from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
        
  end

  #def aging_alert(orders)
  #  @orders = orders
  #  mail to: User.superusers.aging_alerts.map(&:email), subject: "Aging Orders Summary", from: '"Hit The Spot" <do-not-reply@hitthespot.com>'
  #end

end

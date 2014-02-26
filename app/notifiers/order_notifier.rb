class OrderNotifier

  def self.contractor_notifications(order)
    
    email = OrderMailer.contractor_notification(order.id).deliver


    if Rails.env.production? 
      Rails.logger.info "Sending sms to #{order.assigned_to.cell_phone}..."
      begin
        TWILIO.account.sms.messages.create(
          to: "+1#{order.assigned_to.cell_phone}",
          from: SMS_NUMBER,
          body: "New Hit The Spot Order, ##{order.id}! #{order.user.first_name} (cell # #{order.user.cell_phone}). Confirm at - hitthespot://orders/#{order.id}"
        )
      rescue StandardError => e
        Rails.logger.warn "#{e.class} - #{e.message} raised during sms sending in ##{__method__} for order #{order.id}."
      end
    end
    #old --> - or at #{Rails.application.routes.url_helpers.dashboard_order_url(order, host: "www.hitthespot.com", protocol: 'https')}.


  end
  
  def self.location_notifications(order)
    email = OrderMailer.location_notification(order.id)

    # Phone
    # 
    if order.location.notify_phone.present?
      
      host = 'https://www.hitthespot.com' if Rails.env.production? || Rails.env.development? 
      host = 'http://demo.hitthespot.com' if Rails.env.demo? 
      host = 'http://staging.hitthespot.com' if Rails.env.staging? 
      
      Rails.logger.info "Sending Phone Notification to #{order.location.notify_phone}..."
      begin
        TWILIO.account.calls.create(
          to: "+1#{order.location.notify_phone}",
          from: SMS_NUMBER,
          method: 'GET', 
          url: "#{host}/calls/new_call?order_id=#{order.id.to_s}"
        )
      rescue StandardError => e
        Rails.logger.warn "#{e.class} - #{e.message} raised during phone notification sending in ##{__method__} for order #{order.id}."
      end
    end

    # SMS
    # 
    if order.location.sms_phone.present?
      Rails.logger.info "Sending sms to #{order.location.sms_phone}..."
      begin
        TWILIO.account.sms.messages.create(
          to: "+1#{order.location.sms_phone}",
          from: SMS_NUMBER,
          body: "New Hit The Spot Order! Confirm order ##{order.id} (#{ActionView::Base.new.number_to_currency order.total / 100.0}) in your Live Location Dashboard or at #{Rails.application.routes.url_helpers.dashboard_order_url(order, host: "www.hitthespot.com", protocol: 'https')}."
        )
      rescue StandardError => e
        Rails.logger.warn "#{e.class} - #{e.message} raised during sms sending in ##{__method__} for order #{order.id}."
      end
    end

    # Fax
    #
    if order.location.fax_number.present?
      Rails.logger.info "Sending fax to #{order.location.fax_number}..."
      begin
        FaxMachine.send fax_number: "+1#{order.location.fax_number}", data: email.body, file_type: 'TXT'
      rescue StandardError => e
        Rails.logger.warn "#{e.class} - #{e.message} raised during fax sending in ##{__method__} for order #{order.id}."
      end
    end

    email.deliver if order.location.notify_email.present?
  end
end

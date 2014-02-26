class OrderNote < ActiveRecord::Base
  belongs_to :order
  belongs_to :parent, class_name: 'OrderNote', foreign_key: :parent_id
  belongs_to :author, class_name: 'User', foreign_key: :author_id
  
  validates :message, presence: true

  before_save :set_parent
  after_save :send_notifications

  private

  # Private: Set parent note.
  #
  def set_parent
    note = order.notes.last
    if note.present? && note.persisted?
      self.parent = note
    end
  end

  # Private: Send notifications to user.
  #
  def send_notifications
    log_and_notify "Mailer problem on order note notice. Order ##{order.id} OrderNote ##{id}" do
      UserMailer.note_notification(self.id).deliver
    end

    if Rails.env.production? 
      
      if author == order.user
        @cell_number = order.assigned_to.cell_phone
      else
        @cell_number = order.user.cell_phone
      end
      
      @body = "New Hit The Spot Message, Re: Order ##{order.id}: " + "\n" + "\n" + "#{message}" + "\n" + "\n" + "---" + "\n" + "Reply at: hitthespot://orders/#{order.id}/messages"
      
      if @body.length < 161
      
        Rails.logger.info "Sending sms to #{@cell_number}..."
        begin
          TWILIO.account.sms.messages.create(
            to: "+1#{@cell_number}",
            from: SMS_NUMBER,
            body: @body
          )
        rescue StandardError => e
          Rails.logger.warn "#{e.class} - #{e.message} raised during sms sending in ##{__method__} for order #{order.id}."
        end
      else
        Rails.logger.info "Sending sms 1 of 2 to #{@cell_number}..."
        begin
          TWILIO.account.sms.messages.create(
            to: "+1#{@cell_number}",
            from: SMS_NUMBER,
            body: @body[0..150] + " (1 of 2)"
          )
        rescue StandardError => e
          Rails.logger.warn "#{e.class} - #{e.message} raised during sms sending in ##{__method__} for order #{order.id}."
        end
        
        Rails.logger.info "Sending sms 2 of 2 to #{@cell_number}..."
        begin
          TWILIO.account.sms.messages.create(
            to: "+1#{@cell_number}",
            from: SMS_NUMBER,
            body: @body[150..200] + " (2 of 2)"
          )
        rescue StandardError => e
          Rails.logger.warn "#{e.class} - #{e.message} raised during sms sending in ##{__method__} for order #{order.id}."
        end                
        
      end
    end
    
  end
end

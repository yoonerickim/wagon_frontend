module LogAndNotify
  
  module InstanceMethods
    # Internal: Wrap with exception notifier.
    #
    # Catch exceptions of StandardError or specified type. Log error and send
    # Exception Notification to developers.
    #
    # Silly Example:
    # 
    # log_and_notify "Trouble sending message to user.", ActiveRecord::RecordNotFound do
    #   UserMailer.note_notification(self.id).deliver
    # end
    #
    def log_and_notify(message="Default catch & notification", type=Exception)
      begin
        yield
      rescue type => e
        logger.error "ERROR [#{e.class}-#{e.message}]: #{message}" 
        ExceptionNotifier::Notifier.exception_notification(
          e,
          data: {message: message}
        ).deliver
      end
    end
  end

  module ClassMethods
    def log_and_notify(message="Default catch & notification", type=Exception)
      begin
        yield
      rescue type => e
        logger.error "ERROR [#{e.class}-#{e.message}]: #{message}" 
        ExceptionNotifier::Notifier.exception_notification(
          e,
          data: {message: message}
        ).deliver
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

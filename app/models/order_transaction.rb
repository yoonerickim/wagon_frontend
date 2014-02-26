class OrderTransaction < ActiveRecord::Base
  belongs_to :order
  serialize :params
  serialize :message

  scope :successful, where(success: true).order('created_at')
  scope :authorized, where(action: 'authonly').successful.order('created_at')
  scope :captured, where(action: 'capture').successful.order('created_at')

  state_machine :state, initial: :queued do
    event :pend do
      transition :queued => :pending
    end
    event :settle do
      transition :pending => :settled
    end
    event :error do
      transition any => :error
    end
  end

  def response=(response)
    self.success = response.success?
    self.authorization = response.authorization
    self.message = response.message
    self.params = response.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success = false
    self.authorization = nil
    self.message = e.message
    self.params = {}
  end
end

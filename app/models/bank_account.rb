class BankAccount < ActiveRecord::Base
  belongs_to :location
  belongs_to :user

  TYPES = [['Checking', 'checking'],['Savings', 'savings']]
  
  # Set this flag to true if bank account needs to be valid
  attr_writer :required
  attr_accessor :account, :routing

  validates :institution, presence: true
  validate :account_validity, if: :private_attributes_present_or_unsaved?

  #validates :institution, :presence => { :if => :account_required? }
  #validates :account, :presence => { :if => :account_required? }, :numericality => { :allow_blank => true }
  #validates :routing, :presence => { :if => :account_required? }, :numericality => { :allow_blank => true }
  
  before_save :create_payment_method
  before_save :update_payment_method
  before_save :save_last_four

  def required
    @required = true if @required.nil?
    @required
  end

  private

  def stored?
    persisted? && read_attribute(:usa_epay_payment_method_id).present?
  end

  def private_attributes_present_or_unsaved?
    (account.present? && routing.present?) || !persisted?
  end

  def account_required?
    return self.location.integrate_pos == false unless self.location.nil?
    required # use required only if parent location is not saved
  end

  def save_last_four
    self.last_four = account.to_s[-4..-1] if account.present? && bank_account.valid?
  end

  def create_payment_method
    if usa_epay_payment_method_id.blank? && valid?
      options = {
        customer_number: location.usa_epay_customer_id,
        payment_method: { method: bank_account }
      }
      response = GATEWAY.add_customer_payment_method(options)
      if response.success?
        self.usa_epay_payment_method_id = response.message
      else
        logger.debug "Could not save bank account." # TODO notify developers
        logger.debug response.inspect
      end
    end
  end

  def update_payment_method
    if usa_epay_payment_method_id.present? && valid?
      options = {
        method_id: usa_epay_payment_method_id, # TODO this is a hack. should be in payment_method only.
        payment_method: { 
          method_id: usa_epay_payment_method_id,
          method: bank_account
        }
      }
      response = GATEWAY.update_customer_payment_method(options)
      if response.success?
        true
      else
        logger.debug "Could not save bank account." # TODO notify developers
        logger.debug response.inspect
      end
    end
  end

  # Private: Build AM CreditCard
  #
  def bank_account
    @bank_account ||= ActiveMerchant::Billing::Check.new(
      :routing_number =>  routing,
      :account_number =>  account,
      :account_type =>    account_type
    )
    @bank_account
  end

  def account_validity
    @bank_account = nil
    unless bank_account.valid?
      bank_account.errors.each do |key, messages|
        key = case key
              when 'account'
                'account_number'
              when 'routing'
                'routing_number'
              else
                key
              end
        messages.each do |message|
          errors.add key, message
        end
      end
    end
  end
end

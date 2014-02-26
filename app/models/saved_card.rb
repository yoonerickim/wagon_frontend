class SavedCard < ActiveRecord::Base
  belongs_to :user

  attr_accessor :card_number, :card_cvv

  #validates :card_hash, uniqueness: true
  validate :card_validity, unless: :persisted?
  validates :street1, presence: true
  validates :zip, presence: true

  attr_protected :card_hash

  before_validation :hash_card_number
  before_save :create_or_update_usa_epay_payment_method
  before_save :set_last_four
  before_destroy :delete_usa_epay_payment_method

  TYPES = [
    ['Visa', 'visa'], 
    ['American Express', 'american_express'],
    ['Master', 'master'],
    ['Discover','discover']
  ]

  # Public: Full name on card.
  #
  def name
    [first_name, last_name].join ' '
  end

  def row_id
    "card-#{id}"
  end

  private

  # Private: Create a unique, one way hash to identify card.
  #
  # Must be called in a before_validation callback.
  #
  def hash_card_number
    if card_number.present?
      self.card_hash = (Digest::SHA2.new(512) << card_number.to_s).to_s
    end
  end

  def set_last_four
    self.last_four = card_number.to_s[-4..-1] if card_number.present?
  end

  # Private: Create or update a payment method.
  #
  def create_or_update_usa_epay_payment_method
    if usa_epay_payment_method_id.present? # update
      options = {
        method_id: self.usa_epay_payment_method_id,
        method: credit_card,
        billing_address: billing_address
      }
      response = GATEWAY.update_customer_payment_method(options)
      raise SavedCard::NotProcessed.new("Failed to update payment method.") unless response.success?
    elsif user && user.usa_epay_customer_id.present? # create
      options = {
        customer_number: user.usa_epay_customer_id,
        payment_method: { method: credit_card },
        billing_address: billing_address
      }
      response = GATEWAY.add_customer_payment_method(options)
      if response.success?
        self.usa_epay_payment_method_id = response.message
      else
        logger.debug response.inspect
        raise SavedCard::NotProcessed.new("Failed to create payment method.")
      end
    else
      raise "Could not save or update card. Has the user been created? Has usa epay customer id been created?"
    end
  end

  # Private: Delete card from USA ePay.
  #
  def delete_usa_epay_payment_method
    options = {
      customer_number: user.usa_epay_customer_id,
      method_id: usa_epay_payment_method_id
    }
    response = GATEWAY.delete_customer_payment_method(options) if usa_epay_payment_method_id.present?
    logger.debug(response.inspect) unless response.success?
    response.success?
  end

  def card_validity
    unless credit_card.valid?
      credit_card.errors.each do |key, messages|
        key = case key
              when 'number'
                'card_number'
              when 'verification_value'
                'card_cvv'
              when 'month' || 'year'
                'expires_on'
              else
                key
              end
        messages.each do |message|
          errors.add key, message
        end
      end
    end
  end

  # Private: Build AM CreditCard
  #
  def credit_card
    @card ||= ActiveMerchant::Billing::CreditCard.new(
      type: card_type,
      number: card_number,
      verification_value: card_cvv,
      month: expires_on.month,
      year: expires_on.year,
      first_name: first_name,
      last_name: last_name
    )
  end

  def billing_address
    {
      first_name: first_name,
      last_name: last_name,
      address1: street1,
      address2: street2,
      city: city,
      zip: zip
    }
  end

  class NotProcessed < StandardError; end
end

# Order
# 
# Fields:
# id: integer
# user_id: integer - who placed teh order
# location_id: integer - location the order is for
# created_at: datetime - standard
# updated_at: datetime - standard
# tip: integer - tip percentage
# terms: boolean - true if accepted
# tax_rate: float - rate to determine tax
# state: string - pending, submitted, confirmed, etc
# pay_state: string - pending, authorized, captured, etc.
# saved_card_id: integer - card that was charged
# submitted_at: datetime - time sumbitted
# confirmed_at: datetime - time confirmed
# on_delivery_at: datetiem - time on_delivery
# fulfilled_at: datetime - time fulfilled
# canceled_at: datetime - time cancelled (by user or location)
# completed_at: datetime - time either fulfilled, canceled, or undeliverable.
# order_type: integer - SPOT_DELIVERY, TAKE_OUT, etc. Stored as integer.
# assigned_to_id: integer - Who the order is assigned to. Also the deliverer
# use_customer_geometry: boolean - whether or not user has been submitting geometry
#
class Order < ActiveRecord::Base
  include Lock

  SPOT_DELIVERY = '1'
  ADDRESS_DELIVERY = '2'
  TAKE_OUT = '3'
  DINE_IN = '4'
  CONTRACTOR = '5'
  CUSTOM = '6'

  ORDER_TYPES = [ SPOT_DELIVERY, ADDRESS_DELIVERY, TAKE_OUT, DINE_IN, CONTRACTOR, CUSTOM ]

  TIMESTAMPS = [
    :submitted_at, :confirmed_at, :on_delivery_at, 
    :fulfilled_at, :undeliverable_at, :completed_at,
    :canceled_at
  ]
 
  image_accessor :receipt_image
  
  belongs_to :user
  belongs_to :saved_card
  belongs_to :location
  belongs_to :custom_location
  belongs_to :assigned_to, foreign_key: :assigned_to_id, class_name: 'User'
  belongs_to :contractor, foreign_key: :assigned_to_id, class_name: 'User'  
  has_many :line_items
  has_many :transactions, class_name: 'OrderTransaction'
  has_one :delivery_spot
  has_many :notes, class_name: 'OrderNote'
  has_one :vendor, through: :location
  has_many :order_items

  #delegate :delivery_fee, :delivery_minimum, to: :location

  validates :order_type, presence: true, inclusion: { in: ORDER_TYPES }
  validates :approx_cost, presence: true, numericality: { greater_than_or_equal_to: 100, message: "must be greater than $1" } 
  validates :approx_cost, numericality: {less_than_or_equal_to: 20000, message: "must be less than $200" } 
  validates :location_name, presence: true
  validates :custom_order_body, presence: true
  
  #validates :tip, numericality: { greater_than_or_equal_to: 0, message: "must be a positive number" }


  before_create :set_custom_originals
  
  #before_save :set_tax_rate
  before_save :pay_state_callback
  before_save :protect_if_locked
  #before_save :cache_line_items

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :saved_card
  accepts_nested_attributes_for :line_items # for mobile only
  accepts_nested_attributes_for :delivery_spot # for mobile only
  accepts_nested_attributes_for :custom_location
  accepts_nested_attributes_for :order_items

  scope :pending, where(state: 'pending')
  scope :submitted, where(state: 'submitted')
  scope :confirmed, where(state: 'confirmed')
  scope :on_delivery, where(state: 'on_delivery')
  scope :fulfilled, where(state: 'fulfilled')
  scope :active, where(state: ['submitted', 'confirmed', 'on_delivery']).order('created_at ASC')
  scope :tracking_user, where(use_customer_geometry: true)
  scope :completed, where(state: ['fulfilled', 'undeliverable', 'user_canceled', 'location_canceled'])

  scope :authorized, where(pay_state: 'authorized')
  scope :fulfillment_older_than, lambda {|num| where('fulfilled_at < ?', num.minutes.ago)}
  scope :submit_older_than, lambda {|num| where('submitted_at < ?', num.minutes.ago)}

  scope :active_or_tippable, where(
    Order.arel_table[:state].in(['submitted', 'confirmed', 'on_delivery'])
      .or(Order.arel_table[:state].in(['fulfilled', 'undeliverable']).
          and(Order.arel_table[:pay_state].eq('authorized')))
  )
  scope :processable, authorized.fulfilled.fulfillment_older_than(90)
  scope :remindable, submitted.submit_older_than(3)
  scope :aging, submitted.submit_older_than(20)

  scope :ascending, order('submitted_at ASC')
  scope :descending, order('submitted_at DESC')

  state_machine :state, initial: :pending, use_transactions: false do

    # Public: User can cancel the order before confirmed.
    # 
    # The payment authorization is voided. The location will
    # never see the order, but the order is retained for history.
    #
    event :cancel_by_user do
      transition [:pending, :submitted] => :user_canceled
    end

    # Public: User submits the order to the location.
    #
    # This makes the order available to the location for
    # approval. The order total is authorized at this point,
    # before moving to submitted.
    #
    event :submit do
      transition :pending => :submitted
    end

    # Public: Location confirms the order.
    # 
    # At this point the user cannot cancel the order
    # without contacting the location. Order is now being
    # prepared.
    #
    event :confirm do
      transition :submitted => :confirmed
    end

    # Public: Location can cancel the order at any time.
    #
    # The payment is either voided or refunded. The order is
    # retained and viewable by the location.
    #
    event :cancel_by_location do
      transition [:submitted, :confirmed] => :location_canceled
    end

    # Public: Set the order to on delivery.
    #
    # This should be set when the order leaves the facility
    # for delivery. The customer can then be notified his
    # order is on its way.
    #
    event :deliver do
      transition [:confirmed, :location] => :on_delivery
    end

    # Public: Set the order to undeliverable.
    # 
    # This is an optional end state. An order is set to
    # undeliverable when the customer runs away from
    # the delevery person. The payment is captured.
    #
    # If the location, wishes not to charge the customer, the 
    # location should cancel the order (cancel_by_location).
    #
    event :undeliverable do
      transition :on_delivery => :undeliverable
    end

    # Public: Set the order as fulfilled, or complete.
    #
    # At this time the payment is captured if the state is currently
    # authorized. If the state is not authorize the location has
    # manually made a change (voided, refunded, etc.).
    #
    event :fulfill do
      transition [:confirmed, :on_delivery] => :fulfilled
    end

    state :submitted do
      validates :saved_card_id, presence: true, unless: :new_card?
      validate :terms_accepted
      validate :minimum_met
    end
    state :on_delivery do
      validates :assigned_to_id, presence: { unless: :contractor_delivery? }
    end

    before_transition any => [:user_canceled, :location_canceled] do |order, transition|
      order.canceled_at = Time.now
    end
    before_transition any => [:submitted, :confirmed, :on_delivery, :fulfilled] do |order, transition|
      order.attributes = {"#{transition.to}_at" => Time.now}
    end
    before_transition any => [:fulfilled, :undeliverable, :user_canceled, :location_canceled] do |order|
      order.completed_at = Time.now
    end

    after_transition any => [:user_canceled, :location_canceled] do |order, transition|
      order.refund_payment
    end
    after_transition any => :submitted do |order|
      order.authorize_payment
    end
    after_transition any => :confirmed do |order|
      order.log_and_notify "Sending order confirmation to user. Order ##{order.id}" do
        UserMailer.notify_confirmed(order.id).deliver
      end
      
      if Rails.env.production? 
        Rails.logger.info "Sending confirmation sms to customer at #{order.user.cell_phone}..."
        begin
          TWILIO.account.sms.messages.create(
            to: "+1#{order.user.cell_phone}",
            from: SMS_NUMBER,
            body: "Your Hit The Spot Order ##{order.id} has been confirmed and in process!  This means your delivery courier is now working to acquire your order and determine its exact cost.  Track your order at: hitthespot://orders/#{order.id}/track"
          )
        rescue StandardError => e
          Rails.logger.warn "#{e.class} - #{e.message} raised during sms confirmation sending in ##{__method__} for order #{order.id}."
        end
      end      
        
    end

    # Disabling this in favor of allowing the user to change tip. Remove this after
    # we build the task to close out orders.
    #
    after_transition any => [:undeliverable, :fulfilled] do |order, transition|
      if order.payment_authorized?
        order.capture_payment
      else
        true
      end

      BillingActivity.create(:order_id => order.id, :user_id => order.assigned_to.id, :description => "Courier Fee for Order ##{order.id}", :amount => order.courier_fee_in_cents)
      BillingActivity.create(:order_id => order.id, :user_id => order.assigned_to.id, :description => "Reimbursement for Order ##{order.id} (#{order.location_name})", :amount => order.actual_cost)          
            
    end

    after_transition any => [:fulfilled, :undeliverable, :user_canceled, :location_canceled] do |order|
      order.lock
    end
  end

  def state_description
    case state
    when 'pending'
    when 'submitted'
      'Submitted means your Delivery Courier is in the process of receiving and reviewing your order. You will be contacted soon with a status update.'
    when 'confirmed'
      'Confirmed means your Delivery Courier is determining the actual cost of your order.  If this close to your estimated cost (within 35% to be exact) then the courier will pick up the order, snap a photo of the receipt, and communicate with you on progress.'
    end
    
  end
  
  def state_description_for_locations
    case state
    when 'pending'
    when 'submitted'
      '<font style="color:red">The customer is waiting for you to confirm this order!</font>'.html_safe
    when 'confirmed'
      'Make sure to let the customer know when the order is ready!'
    end
  end
  
  def state_description_for_contractors
    case state
    when 'pending'
    when 'submitted'
      '<font style="color:red">The customer is waiting for you to confirm this order!</font>'.html_safe
    when 'confirmed'
      'Make sure to let the customer know when the order is ready!'
    end
  end
  


  state_machine :pay_state, initial: :pending, namespace: 'payment', use_transactions: false do

    # Public: Authorize the payment for the order.
    # 
    # This authorizes the total with the gateway. To stop
    # the payment you can void.
    #
    event :authorize do
      transition :pending => :authorized
    end

    # Public: Void the the payment.
    #
    # Cancel the payment. The charge will not be seen
    # on the customers statement.
    #
    # This can only be done before a batch has been settled,
    # for our purposes this can only be done before capture, 
    # when in reality once captured time may pass before the 
    # batch is settled.
    #
    event :void do
      transition [:authorized] => :voided
    end

    # Public: Capture the payment.
    #
    # This is executed by the location manually or when 
    # the order is fulfilled or set to undeliverable. Capturing
    # allowes the payment to be settled.
    #
    event :capture do
      transition :authorized => :captured
    end

    # Internal: Settle the payment.
    #
    # This is only meant to be called by the system when 
    # the order is settled.
    #
    event :settle do
      transition :captured => :settled
    end

    # Public: Refund the payment.
    #
    # Internally, if the order has not been settled, status
    # is checked and the order is voided if not settled. Otherwise
    # the normal course of action is to credit back the 
    # total.
    #
    event :refund do
      transition [:captured, :settled] => :refunded, :if => lambda {|order| order.is_settled?}
      transition [:authorized, :captured] => :voided
    end

    after_transition any => :captured do |order|
      order.reload # required so callbacks don't fire twice
      order.lock
    end

  end

  # Public: Process orders.
  #
  # Meant to be called from rake every 30 minutes.
  #
  # Gathers orders that are fulfilled and authorized (ie. have not been
  # captured by the customer changing the tip.) and captures them.
  #
  def self.process!
    Order.processable.each do |order|
      order.capture_payment
    end
  end

  def self.remind!
    Order.remindable.each do |order|
      log_and_notify "Mailer problem on location confirmation reminders. Order ##{order.id}" do
        OrderNotifier.location_notifications(order)
      end
    end
  end

  def self.aging_alerts!
    log_and_notify "Mailer problem on superuser notification of aging orders." do
      OrderMailer.aging_alert(Order.aging).deliver
    end
  end

  # Public: Test if order is complete.
  #
  # NOTE: state changes in state_machine.
  #
  def complete?
    [:user_canceled, :location_canceled, :fulfilled, :undeliverable].include? state_name
  end

  # Public: Test if order is for delivery
  #
  # Returns true if a spot or address delivery.
  def delivery_order?
    [SPOT_DELIVERY, ADDRESS_DELIVERY, CONTRACTOR, CUSTOM].include?(order_type.to_s)
  end

  def current_delivery_spot
    if self.use_customer_geometry
      self.user.geometry
    else
      self.delivery_spot
    end
  end

  
  def order_type_word
    case order_type.to_s
    when DINE_IN
      'Dine-in'
    when TAKE_OUT
      'Take-out'
    else
      'Delivery'
    end
    
  end

  def new_card?
    self.saved_card.present? && !self.saved_card.persisted?
  end

  # Public: Set contractor_delivery if a contractor is required to deliver to specified
  # location.
  #
  # Sets but does not save contractor_delivery.
  #
  # Returns true if contractor_delivery.
  def set_contractor_delivery
    location.can_deliver?(to: delivery_spot.coordinates)
    if location.delivery_via_contractor
      self.contractor_delivery = true
      self.order_type = Order::CONTRACTOR
      self.contractor_id = location.contractor_available(to: delivery_spot.coordinates).id
    end
  end

  # Public: Capture the order with a tip.
  #
  def capture_with_tip(tip=self.tip)
    return unless (confirmed? || on_delivery? || fulfilled? || undeliverable?) && payment_authorized?
    self.tip = tip if tip.present? 
    self.capture_payment
  end

  # Public: Formats data for order row.
  #
  def delivery_data
    data = []
    #all orders custom orders for now ---> if delivery_order?
      data << %Q|data-spot-lat="#{delivery_spot.lat}"|
      data << %Q|data-spot-lng="#{delivery_spot.lng}"|
      if on_delivery?
        data << %Q|data-delivery-lat="#{assigned_to.try(:geometry).try(:lat)}"|
        data << %Q|data-delivery-lng="#{assigned_to.try(:geometry).try(:lng)}"|
      end
      data << %Q|data-location-lat="#{custom_location.lat}"|
      data << %Q|data-location-lng="#{custom_location.lng}"|
      
      
    #end
    data.join(' ').html_safe
  end

  # Public: Subtotal of all line items.
  #
  def subtotal
    line_items.inject(0) { |sum, line_item| sum + line_item.subtotal }
  end

  # Public: Get the tip amount.
  #
  def tip_amount
    (subtotal * ((tip || 0) / 100.0)).round
  end

  # Public: Get tax for the order.
  #
  def tax
    (subtotal * (location.try(:tax_rate) || 0.095)).round # NOTE: defaults to seattle tax rate
  end

  def delivery_fee
    if actual_cost.present? 
      if (actual_cost.to_f / 100.0) * 0.3 > 6
        thefee = (actual_cost.to_f / 100.0) * 0.3
      else
        thefee = 6
      end      
    else
      if (approx_cost.to_f / 100.0) * 0.3 > 6
        thefee = (approx_cost.to_f / 100.0) * 0.3
      else
        thefee = 6
      end      
    end    
    thefee
  end


  def courier_fee_in_cents
    if actual_cost.present? 
      if actual_cost.to_f * 0.2 > 500
        thefee = actual_cost.to_f * 0.2
      else
        thefee = 500
      end      
    else
      if approx_cost.to_f * 0.2 > 500
        thefee = approx_cost.to_f * 0.2
      else
        thefee = 500
      end      
    end    
    thefee.floor
  end

  # Public: Get the order total.
  #
  def total
    #subtotal + tax + ( delivery_order? ? location.delivery_fee : 0 ) + tip_amount
    if actual_cost.present? 
      thetotal = (actual_cost.to_f / 100.0) + delivery_fee  
    else
      thetotal = (approx_cost.to_f / 100.0) + delivery_fee  
    end
    thetotal
  end
    
  # Public: Cache the order's line_items (and in turn: options)
  #
  def cache!
    line_items.each(&:cache!)
  end

  def need_to_reauthorize?
    last_auth = transactions.authorized.last
    last_auth.present? && last_auth.amount < total_in_cents && (payment_authorized? || payment_captured?)
  end

  # Public: Reauthorize order if new total is higher than last authorized amount
  #
  def reauthorize
    last_auth = transactions.authorized.last
    if last_auth.present? && last_auth.amount < total_in_cents && (payment_authorized? || payment_captured?)
      logger.info "Order #{id}: Need to reauthorize. (Total higher than last authorization.)"
      #void the last auth
      before_voided
      #get a new auth
      before_authorized
    else
      logger.info "Order ##{id} (#{state} - #{pay_state}) tried to " +
        "reauthorize, but did not meet criteria. This is ok."
      true
    end
  end

  # Private: Determine if order is settled.
  #
  def is_settled?
    logger.debug "Checking Status....."
    options = {
      reference_number: transactions.authorized.last.authorization
    }
    response = GATEWAY.get_transaction_status(options)
    if response.success?
      response.message['status_code'] == 'S' # settled
    else
      false
    end
  end

  # Public: Define children to lock/unlock.
  #
  def lockable_children
    self.line_items
  end

  def minimum_met?
    #self.subtotal >= self.delivery_minimum
    true
  end
  
  def self.assign_delivery_contractor(available_contractors)        
    available_contractors.first.id 
  end 

  def deliverer
    puts "HEY", state
    if state == 'on_delivery'
      puts 'SEND'
      assigned_to
    else
      nil    
    end
  end

  class RecordNotFound < StandardError; end

  private

  def cache_line_items
    self.cache!# if [:submitted, :confirmed, :on_delivery].include? self.state_name
  end

  # Private: Make sure tax rate set.
  #
  def set_tax_rate
    self.tax_rate = order.location.try(:tax_rate) || 0.095 if self.tax_rate.blank?
  end

  # Private: Don't allow locked items to be saved.
  #
  def protect_if_locked
    if locked? && locked_was == true
      logger.warn "Order #{id}: Sanitizing locked parameters."

      self.class.column_names.reject{|name| name =~ /state|_at|locked/ }.each do |attribute|
        self.send(:"#{attribute}=", self.send(:"#{attribute}_was")) if send(:"#{attribute}_changed?")
      end
    end
    true
  end

  # Private: Validate terms are accepted.
  #
  def terms_accepted
    unless self.terms == true
      errors.add :terms, 'must be accepted'
    end
  end

  # Private: Validate minumum delivery total met.
  #
  def minimum_met
    # unless minimum_met?
    #   errors.add :subtotal, 
    #     "must be at least #{ActionView::Base.new.number_to_currency(self.delivery_minimum / 100.0)}"
    # end
  end

  # Private: Call callback for event.
  #
  def pay_state_callback(before_or_after = :before)
    return unless pay_state_changed?

    method_name = :"#{before_or_after}_#{pay_state}"
    send(method_name) if respond_to?(method_name, true)
  end

  def before_authorized
    logger.info "\n\nOrder #{id}: Authorizing\n"
    options = {
      command: 'authonly',
      customer_number: saved_card.user.usa_epay_customer_id,
      method_id: saved_card.usa_epay_payment_method_id,
      amount: total_in_cents
    }
    response = GATEWAY.run_customer_transaction(options)

    if response.success?
      logger.info "\n\nOrder #{id}: Authorized: #{response.authorization}\n"
    else
      logger.info "\n\nOrder #{id}: Failed Authorization: #{response.message}"
      logger.info "#{response.params}\n"
    end

    transactions.create(
      action: options[:command], 
      amount: options[:amount], 
      saved_card_id: saved_card.id, 
      response: response
    )

    if response.success?
      self.submitted_at = Time.now
    else
      errors.add(:base, "card not authorized")
    end
    response.success?
  end

  def before_voided
    logger.debug "Voiding......"
    options = {
      reference_number: transactions.authorized.last.authorization
    }
    response = GATEWAY.void_transaction(options)
    logger.debug response.inspect

    transactions.create(
      action: 'void',
      response: response,
    )

    errors.add(:base, "could not be voided") unless response.success?
    response.success?
  end

  def before_captured
    logger.info "\n\nOrder #{id}: Attempting Capture: Order is #{state}\n"
      
    reauthorize # if needed

    # Don't allow transition unless order is at or after the confirmed state.
    #
    return false if [:pending, :submitted].include?(state_name)
    logger.info "\n\nOrder #{id}: Capturing\n"

    options = {
      reference_number: transactions.authorized.last.authorization,
      amount: total_in_cents,
    }
        
    response = GATEWAY.capture_transaction(options)

    if response.success?
      logger.info "\n\nOrder #{id}: Captured: #{response.authorization}\n"
    else
      logger.info "\n\nOrder #{id}: Failed Capture: #{response.message}"
      logger.info "#{response.params}\n"
    end

    transactions.create(
      action: 'capture', 
      amount: options[:amount], 
      response: response
    )

    errors.add(:base, "could not be captured") unless response.success?
    response.success?
  end

  def before_refunded
    logger.debug "Refunding......"
    options = {
      reference_number: transactions.captured.last.authorization
    }
    response = GATEWAY.run_quick_credit(options)
    logger.debug response.inspect

    transactions.create(
      action: 'credit', 
      response: response
    )

    errors.add(:base, 'could not be refunded') unless response.success?
    response.success?
  end
      
      
  def set_custom_originals    
    self.custom_order_body_original = custom_order_body
    self.location_name_original = location_name  
  end  
  
  def total_in_cents
    #change it to cents, because def total changes it to USD
    (total.to_f * 100.00).floor
  end
  
end

# Overriding validation method. USA ePay does not need a name.
#
class ActiveMerchant::Billing::Check

  # Monkey patch!!! Remove when Gatway uses account_number rather than number.
  #
  def account_number=(value)
    @account_number = @number = value
  end

  def validate
    [:routing_number, :account_number].each do |attr|
      errors.add(attr, "cannot be empty") if self.send(attr).blank?
    end

    errors.add(:routing_number, "is invalid") unless valid_routing_number?

    errors.add(:account_holder_type, "must be personal or business") if
    !account_holder_type.blank? && !%w[business personal].include?(account_holder_type.to_s)

    errors.add(:account_type, "must be checking or savings") if
    !account_type.blank? && !%w[checking savings].include?(account_type.to_s)
  end
end

# DeliveryHour
#
class DeliveryHour < TimeSlot
  default_scope where(delivery: true)
end

# Hour
# 
class Hour < TimeSlot
  default_scope where(delivery: false)

end

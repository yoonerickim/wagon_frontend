module Dollars
  module ClassMethods
  end

  module InstanceMethods
    # Takes 7.99 or "7.99" to set price (in cents)
    # at 799.
    #
    def dollars=(dollars)
      @price = (dollars.to_f)*100.floor
    end

    # Returns price in a float. 799 becomes 7.99
    #
    def dollars
      @price.to_f/100
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

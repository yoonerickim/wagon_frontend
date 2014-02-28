module Sanitizers
  module ClassMethods
    
  end

  module InstanceMethods

    # Public: Clean up a number. Removes all non-digits.
    #
    # number - A number (string) to sanitize.
    #
    # Returns a clean number as a string or nil if number was nil.
    def strip_non_digits(number)
      number ? number.to_s.gsub(/\D/,'') : number
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

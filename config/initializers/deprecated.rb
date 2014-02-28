# Add a deprecated method to ActiveRecord::Base so we can warn when we are using
# methods that will be going away.
#
ActiveRecord::Base.class_eval do

  # Public: Warn when a method is deprecated.
  #
  # message - What you want to print.
  #
  # Example:
  # 
  #   class Location < ActiveRecord::Base
  #     
  #     def do_it
  #       deprecated("You should not call Location#do_it!!!")
  #       # original method body
  #     end
  #
  #   end
  #
  define_method(:depricated) do |message="You are using a depricated method."|
    logger.warn("DEPRICATED: #{message.to_s}")
  end
end

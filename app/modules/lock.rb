module Lock
  
  # Public: Lock the record.
  #
  # Return true if saved.
  def lock(options = {})

    Rails.logger.debug "---- LOCK #{self.class} id: #{self.try(:id)} #{options.inspect}"

    result = true
    if options.length == 0 || options[:only] == :parent
      self.locked = true
      self.save
    end
    if (options.length == 0 || options[:only] == :children) && respond_to?(:lockable_children)
      lockable_children.map(&:lock)
    end
    nil
  end

  # Public: Unlock the record.
  #
  # Return true if saved.
  def unlock(options = {})

    Rails.logger.debug "---- UNLOCK #{self.class} #{self.try(:id)} #{options.inspect}"
    
    if options.length == 0 || options[:only] == :parent
      self.locked = false
      self.save
    end
    if (options.length == 0 || options[:only] == :children) && respond_to?(:lockable_children)
      lockable_children.map(&:unlock)
    end
    nil
  end

end

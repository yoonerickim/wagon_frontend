class LiveLocationUser

  attr_reader :location

  # Public: Set a location.
  #
  def initialize location=nil
    @location = location
  end

  # Public: Render role if location set.
  #
  def role_symbols
    @location.present? ? [:live_location] : []
  end

  # Public: Get id of location.
  #
  def location_id
    @location.id if @location.present?
  end

end

module HomeHelper

  # Public: Build link to location's menus overlay.
  #
  # Returns a link.
  def menus_link(location, delivery_type)
    case delivery_type
    when Order::SPOT_DELIVERY
      text = "Order for Delivery"
    when Order::ADDRESS_DELIVERY
      text = "Order for Delivery"
    when Order::TAKE_OUT
      text = "Order take-out"
    when Order::DINE_IN
      text = "Order for dine-in"
    end
    link_to text, menus_location_path(location, type: delivery_type), remote: true
  end

  def spot_order_path(spot)
    if spot.spot?
      parameters = {lat: spot.lat, lng: spot.lng, t: Order::SPOT_DELIVERY}
    else
      parameters = {a: spot.spot_formatted, t: Order::ADDRESS_DELIVERY}
    end
    map_path(parameters)
  end

  # Public: Highlight the first matching tag for a location.
  #
  def matching_tag(location, term)
    return unless term.present?
    match = location.tags.matching(term).first
    yellow_highlight match.name, term if match.present?
  end

  # Public: Present highlighted links for items matching search term.
  #
  # Will only return links if the menu they belong to is active. If
  # the location is not delivering or open, it will return all items
  # for off hours searching.
  #
  def matching_menu_item_links(location, term, type)
    return unless term.present?
    links = []
    items = location.menu_items.matching(term)
    items.each do |item|
      if item.menu.active? || !item.location.delivering? || !item.location.open?
        links << link_to(yellow_highlight(item.name, term), 
                         menus_location_path(location, type: type, menu_item_id: item.id), 
                         remote: true, class: "should_open_menu_overlay_when_clicked")
      end
    end
    links.join('<br />').html_safe
  end

end

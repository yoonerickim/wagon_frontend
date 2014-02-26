module LocationsHelper

  # Public: A method for menu_action helper method.
  #
  # Use this method when an order is being built.
  #
  def place_order_link order
    link_to("Confirm Order &raquo;".html_safe, place_order_path(order), 
            method: :post, id: 'place_btn', style: 'display: none;')
  end

  def menu_class menu
    menu.active? ? 'active' : 'inactive'
  end

end

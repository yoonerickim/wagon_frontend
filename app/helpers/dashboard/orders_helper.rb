module Dashboard::OrdersHelper

  # Public: A method for menu_action helper method.
  #
  # Use this method when an order is being edited in by the vendor.
  #
  def location_update_link order
    link_to("Reauthorize &raquo;".html_safe, dashboard_order_reauthorize_path(order), 
            method: :post, remote: true, id: 'place_btn')
  end

  # Public: A method for menu_action helper method.
  #
  # Use this method when an order is being edited after checkout
  # by the user who created the order.
  #
  def user_update_link order
    link_to("Done &raquo;".html_safe, dashboard_order_user_update_path(order), 
            method: :put, remote: true, id: 'place_btn')
  end

end

module OrdersHelper

  # Public: A method for menu_action helper method.
  #
  # Use this method when an order is being edited in checkout.
  #
  def checkout_update_link order
    link_to("Update Order &raquo;".html_safe, order_path(order), 
            remote: true, method: :put, id: 'place_btn')
  end

end

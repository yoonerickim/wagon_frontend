class LineItemsController < ApplicationController
  respond_to :js

  # Called from "Choose Options" or "Add" when there are options.
  #
  def new
    @item = MenuItem.find(params[:menu_item_id]) # TODO make local var
    @order = Order.find(params[:order_id])
    @line_item = LineItem.new(item: @item, quantity: (params[:quantity] || 1)) # TODO use quantity from overlay
    @item.option_count.times { @line_item.options.build }
    render 'edit'
  end

  # Add a line item to the current order.
  #
  # Creates a LineItem and returns a JS template updating the overlay with
  # the new LineItem.
  #
  def create
    @line_item = LineItem.new(params[:line_item])
    @order = Order.find(params[:order_id])
    @line_item.order_id = @order.id
    
    if @line_item.save
      render 'update'
    else
      render 'edit'
    end
  end

  # Called when an order line item is clicked to edit.
  #
  def edit
    @line_item = LineItem.find(params[:id])
    if params[:frame] == 'true'
      @order = Order.find(params[:order_id]) if params[:frame] == 'true'
      @frame = true
    end
  end

  # Commit action for edit.
  #
  def update
    @line_item = LineItem.find(params[:id])
    if @line_item.update_attributes(params[:line_item])
      @order = Order.find(params[:order_id])
      render 'update'
    else
      render 'edit'
    end
  end

  # Remove a LineItem from an order.
  # 
  # Deletes the LineItem from the current order and returns a JS template updating
  # the Overlay with out the LineItem.
  #
  def destroy
    @line_item = LineItem.find(params[:id])
    @order = Order.find(params[:order_id])
    @line_item.destroy if @line_item.present?
    render 'update'
  end

end

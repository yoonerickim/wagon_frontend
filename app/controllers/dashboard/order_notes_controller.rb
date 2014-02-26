class Dashboard::OrderNotesController < ApplicationController
  def create
    @order_note = OrderNote.new(params[:order_note])
    @order_note.author_id = current_user.id
    @order_note.save
    @order = @order_note.order
    render 'dashboard/orders/status'
  end
end

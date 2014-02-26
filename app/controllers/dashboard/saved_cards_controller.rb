class Dashboard::SavedCardsController < ApplicationController
  before_filter :find_card, only: [:edit, :update, :destroy]
  filter_access_to :all

  def new
    @saved_card = current_user!.saved_cards.build
    render 'edit'
  end

  def create
    @saved_card = current_user!.saved_cards.build
    @saved_card.attributes = params[:saved_card]

    if @saved_card.save
      @user = @saved_card.user
      render 'update'
    else
      render 'edit'
    end
  end

  def update
    if @saved_card.update_attributes(params[:saved_card])
      @user = @saved_card.user
    else
      render 'edit'
    end
  end

  def destroy
    @saved_card.destroy if @saved_card.present?
  end

  private

  def find_card
    @saved_card = current_user!.saved_cards.find(params[:id])
  end
end

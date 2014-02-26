class Dashboard::SpotsController < ApplicationController
  before_filter :build_spot, only: [:new, :create]
  filter_access_to :all, attribute_check: true
  respond_to :js

  def index
    @spots = current_user.spots
  end
  
  def new
    @path = dashboard_spots_path # TODO This can go away if/when we refactor addresses/spots
    render 'edit'
  end

  def create
    @spot.attributes = params[:address]

    if @spot.save
      @user = @spot.addressable
      render 'update'
    else
      @path = dashboard_spots_path # TODO This can go away if/when we refactor addresses/spots
      render 'edit'
    end
  end

  def edit
    @spot = Spot.find(params[:id])
    @path = dashboard_spot_path(@spot) # TODO This can go away if/when we refactor addresses/spots
  end

  def update
    @spot = Spot.find(params[:id])

    if @spot.update_attributes(params[:address])
      @user = @spot.addressable
    else
      @path = dashboard_spot_path(@path) # TODO This can go away if/when we refactor addresses/spots
      render 'edit'
    end
  end

  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy if @spot.present?
  end

  private

  def build_spot
    @spot = current_user.spots.build
  end

end

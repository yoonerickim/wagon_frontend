class Dashboard::MenusController < ApplicationController
  before_filter :build_menu, only: [:new, :create]
  filter_access_to :all, attribute_check: true

  def new
    render 'dashboard/menus/_edit.html.erb', layout: false
  end

  def create
    respond_to do |format|
      if @menu.save
        format.js { render 'close' }
      else
        format.js { render 'edit' }
      end
    end
  end

  def edit
    @menu = Menu.find(params[:id])
    render 'dashboard/menus/_edit.html.erb', layout: false
  end

  def update
    @menu = Menu.find(params[:id])
    respond_to do |format|
      if @menu.update_attributes(params[:menu])
        format.js { render 'close' }
      else
        format.js { render 'edit' }
      end
    end
  end

  private

  def build_menu
    if params.has_key?(:location_id)
      @menu = Menu.new(location_id: params[:location_id])
    else
      @menu = Menu.new(params[:menu])
    end
  end
end

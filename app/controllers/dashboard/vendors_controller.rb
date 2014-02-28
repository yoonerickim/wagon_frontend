class Dashboard::VendorsController < ApplicationController
  force_ssl
  filter_access_to :index
  filter_access_to :all, attribute_check: true
  
  def index
    @title = "Vendors and Locations | Hit The Spot"
    @vendors = current_user.associated_vendors
  end

  def new
    @vendor = Vendor.new
    @location = @vendor.locations.build
    @location.build_registration_objects
    @user = current_user! # TODO check if this should go... I think it should
    @tag_ids = @location.tag_ids
    retrieve_tags

    @origin = {'lat' => '47.61356975397398', 'lng' => '-122.3382568359375'} # Why is this here?
  end
  
  def create # TODO clean me
    @vendor = Vendor.new
    @location = @vendor.locations.build
    @location.attributes = params[:vendor].delete(:location)    
    @vendor.attributes = params[:vendor]

    # Need to create a new role
    @vendor.roles.build(:user_id => current_user.id, :active => true, :roletype_id => 2)

    if @vendor.save
      redirect_to edit_dashboard_vendor_path(@vendor), :notice => "Vendor created!"
    else
      @user = current_user! # TODO check if this can go too
      @tag_ids = @location.tag_ids
      retrieve_tags

      @origin = {'lat' => '47.61356975397398', 'lng' => '-122.3382568359375'} # Why is this here?
      render 'new'
    end
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update_attributes(params[:vendor])
      redirect_to edit_dashboard_vendor_path(@vendor), :notice => "Vendor Updated"
    else
      render 'edit'
    end
  end

  private

  def retrieve_tags
    @tags = Tag.standard
    @extra_tags = Tag.extra
  end

end

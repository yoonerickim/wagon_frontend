class Dashboard::LocationsController < ApplicationController
  force_ssl
  filter_access_to :all, attribute_check: true

  def show
    @location = Location.find(params[:id]) 
    @title = @location.full_display_name + ' | Hit The Spot'
    @vendor = @location.vendor
  end

  def live
    self.live_location = Location.find(params[:id])
    redirect_to dashboard_live_url
  end

  def openmenu_refresh
    @location = Location.find(params[:id])
    @location.build_openmenu
    @test_only_message = @location.save ? "successfully!" : "unsuccessfully please call tech support."
  end

  def new
    @vendor = Vendor.find(params[:vendor_id])
    @location = @vendor.locations.build
    @location.build_registration_objects

    @tag_ids = @location.tags.collect { |t| t.id }

    @tags = Tag.standard
    @extra_tags = Tag.extra
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      redirect_to dashboard_location_path(@location)
    else
      @tag_ids = @location.tags.collect { |t| t.id }

      @tags = Tag.standard
      @extra_tags = Tag.extra

      render 'new'
    end
  end
  
  def edit
    @location = Location.find(params[:id])
    @location.build_registration_objects
    @tag_ids = @location.tags.collect { |t| t.id }

    @tags = Tag.standard
    @extra_tags = Tag.extra
  end

  def update
    @location = Location.find(params[:id])
    
    if @location.update_attributes(params[:location])
      redirect_to edit_dashboard_location_path(@location), :alert => "Updated location"
    else
      @location.build_registration_objects
      @tag_ids = @location.tags.collect { |t| t.id }

      @tags = Tag.standard
      @extra_tags = Tag.extra
      render 'edit'
    end
  end

  def update_notifications
    @location = Location.find(params[:id])
    @location.sms_phone = params[:location][:sms_phone]
    @location.notify_phone = params[:location][:notify_phone]    
    @location.notify_email = params[:location][:notify_email]
    flash.now.notice = "Updated!" if @location.save
  end

end

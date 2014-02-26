class HomeController < ApplicationController
  include GeoKit::Geocoders
  skip_before_filter :verify_authenticity_token, :only => [:send_mobile_feedback]
  
  def index
    @page_title = "Hit The Spot | Food that finds you"
    @page_description = "Say goodbye to old-school address delivery and hello to GPS-based awesomeness. Order what you want and let food find you."
    @og_description = @page_description
    @og_title = @page_title 
    @og_img = "http://hts-production.s3.amazonaws.com/assets/social-media-logo.png"
    
    #render 'preview_landing' #using this until we launch 
    redirect_to '/', :status => 301
  end
  
  def home
    
    #render 'index'
    redirect_to '/', :status => 301
  end
  
  def new_home
    
    @page_title = "Hit The Spot | Food that finds you"
    @page_description = "Say goodbye to old-school address delivery and hello to GPS-based awesomeness. Order what you want and let food find you."
    @og_description = @page_description
    @og_title = @page_title 
    @og_img = "http://hts-production.s3.amazonaws.com/assets/social-media-logo.png"

    render 'index'  
    
  end

  def owners
    @title = "Restaurant Owners | Hit The Spot"
    @vendor = Vendor.new
    @vendor.roles.build.build_user
    
    redirect_to '/couriers', :status => 301
  end
  
  def couriers
    @title = "Become a Hit The Spot Delivery Courier"
    @vendor = Vendor.new
    @vendor.roles.build.build_user
  end  

  def about
    @page_title = "About Hit The Spot | GPS-Based Food Delivery"
    @page_description = "The story behind our GPS-based food ordering and delivery service."
    @og_description = @page_description
    @og_title = @page_title 
    @og_img = "http://hts-production.s3.amazonaws.com/assets/social-media-logo.png"
  end

  def preview_landing
    @page_title = "Hit The Spot | Food that finds you"
  end

  def mobile_about
    render :layout => false 
  end
  
  def confirm_location
    
    @delivery_type = Order::CUSTOM
    @placeholder_for_move_spot_input = 'Enter address or location'

    if params[:lat].present? and params[:lng].present? 
      @origin = {:lat => (params[:lat].to_f + 0.001).to_s, :lng => (params[:lng].to_f + 0.001).to_s}            
      if not User.contractors_available?(@origin)
        flash[:notice] = "Sorry - deliveries are currently not available to your spot at this time. Follow us on Facebook (/HitTheSpotDelivery) or Twitter (@HitTheSpot) to stay updated on the rollout of coverage zones."
        redirect_to '/confirm_spot?a=' + URI.escape(params[:a]) + '&lat=' + params[:lat] + '&lng=' + params[:lng]
      end  
      
      
    else
      redirect_to '/'
    end

  end
  
    
  def confirm_spot
    @delivery_type = Order::CUSTOM
    @placeholder_for_move_spot_input = 'Enter address or location'
    
    # Set the origin. I there is not lat/lng try to geocode address.
    # If that fails set to seattle origin.
    #
    if params[:lat].present? && params[:lng].present?
      @origin = {:lat => params[:lat], :lng => params[:lng]}
    elsif params[:a].present?
      geo =  GoogleGeocoder.geocode(params[:a])
      if geo.success?
        @origin = {:lat => geo.lat, :lng => geo.lng}
      else
        @origin = {:lat => '47.60621', :lng => '-122.332071'}
      end
    else
      @origin = {:lat => '47.60621', :lng => '-122.332071'}
    end
    
    if not User.contractors_available?(@origin)
      flash[:notice] = "Sorry - deliveries are not available to that spot at this time. Follow us on Facebook (/HitTheSpotDelivery) or Twitter (@HitTheSpot) to stay updated on the rollout of coverage zones."
      redirect_to '/'
    end  
                    
  end

  def map
    @page_title = "Preview"

    begin
      @delivery_type = params[:t]
      @placeholder_for_move_spot_input = 'Enter address or location'
      case @delivery_type
        when Order::SPOT_DELIVERY
          @listings_heading = 'Restaurants that deliver to the current spot'
        when Order::ADDRESS_DELIVERY
          @listings_heading = 'Restaurants that deliver to this address'
          @placeholder_for_move_spot_input = 'Enter exact street address'
        when Order::TAKE_OUT
          @listings_heading = 'Take-out options near the current spot'
        when Order::DINE_IN
          @listings_heading = 'Dine-in options near the current spot'
        else
          raise ArgumentError.new("Home page param does not match an order type.")
      end
    rescue StandardError
      redirect_to root_path
    end

    # Set the origin. I there is not lat/lng try to geocode address.
    # If that fails set to seattle origin.
    #
    if params[:lat].present? && params[:lng].present?
      @origin = {:lat => params[:lat], :lng => params[:lng]}
    elsif params[:a].present?
      geo =  GoogleGeocoder.geocode(params[:a])
      if geo.success?
        @origin = {:lat => geo.lat, :lng => geo.lng}
      else
        @origin = {:lat => '47.60621', :lng => '-122.332071'}
      end
    else
      @origin = {:lat => '47.60621', :lng => '-122.332071'}
    end
  end
  
  def voicemail
    #render :layout => false
    respond_to do |format|
            #format.html # index.html.erb
            format.xml  # { render :xml =>   @items }
    end
  end

  def smsreply
    #render :layout => false
    respond_to do |format|
            #format.html # index.html.erb
            format.xml  # { render :xml =>   @items }
    end
  end
  
  def terms
    
    @page_title = "Hit The Spot | Terms and Conditions"
    
  end

  def save_email
    
    respond_to do |format|
      if params[:email].present? and params[:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i) 
        begin 
          User.create!(email: params[:email], :email_only => true, :first_name => params[:email].scan(/(.*?)@/)[0][0], :last_name => 'change_me')
          @good_to_go = true
          @response = "Cheers. We'll keep you posted!" 
          format.js { render 'email_submitted_response' }
        rescue
          @response = 'Got it! We already have your email in our system and will keep you posted!'
          format.js { render 'email_submitted_response' }          
        end
      else
        @response = 'Make sure your email is correct.'
        format.js { render 'email_submitted_response' }
      end
    end    
  end
  
  def send_mobile_feedback
    
    if params[:body].present? and params[:email].present? 
      
      UserMailer.generic_message("info@hitthespot.com", "Feedback from the HTS mobile app", "From: #{params["email"]}" + "\n" + "\n" + "#{params["body"]}").deliver                      
      
      respond_to do |format|
        format.js {}
      end            
    else  
      render :nothing => true
    end
    
    
  end  

end

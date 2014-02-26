class VendorsController < ApplicationController
  before_filter :setorigin # TODO don't think this is needed
  
  def setorigin
    @origin = {}
    @origin['lat'] = '47.61356975397398'
    @origin['lng'] = '-122.3382568359375'
  end
  
  def new
    @vendor = Vendor.new
    @vendor.roles.build.build_user
  end

  # TODO need to be able to handle a vendor already with a user - block "already signed up"
  # TODO need to handle a pre-existing user
  def create
    @vendor = Vendor.new(params[:vendor])
    @vendor.registerable = true # required to create registation_token
    if @vendor.save
      
      #turning this off for now
      #@vendor.send_welcome_email
      
      @vendor.send_admin_notification_email

      #first role's roletype is a vendor exec
      @role = @vendor.roles.first
      @role.roletype_id = Role::VENDOR_EXEC
      @role.save
      
      @email = @vendor.users.first.email
      
      render 'home/thankyou', :notice => "Thank you! A Hit The Spot representive will be contacting you soon."
    else
      render 'new'
    end
  end

  def registration
    vendor = Vendor.find_by_registration_token!(params[:id])
    raise ActiveRecord::RecordNotFound if vendor.users.count != 1 # TODO test me

    @location = vendor.locations.build
    @location.build_registration_objects
    Link::VENDOR_NAMES.each { |link| @location.vendor.links.build(:name => link) }
    @tag_ids = @location.tag_ids
    @user = vendor.users.first
    @role = vendor.roles.where(:user_id => @user.id).first
    retrieve_tags
  end

  def register
    vendor = Vendor.find_by_registration_token!(params[:id])
    raise ActiveRecord::RecordNotFound if vendor.users.count != 1 # TODO test me

    params[:user][:vendor_terms] ||= false # clear vendor terms if not checked
    params[:location][:tag_ids] ||= []
    #bank_account_attributes = params[:location].delete(:bank_account_attributes)
    pos_account_attributes = params[:location].delete(:pos_account_attributes)
    #billing_method_attributes = params[:location].delete(:billing_method_attributes)

    @location = vendor.locations.build
    @location.attributes = params[:location] # TODO why cant the params go in build? ActiveRecord::RecordNotFound
    
    #bank_account = @location.build_bank_account(bank_account_attributes)
    pos_account = @location.build_pos_account(pos_account_attributes)
    #billing_method = @location.build_billing_method(billing_method_attributes)
    #params[:location][:integrate_pos] =~ /true/ ? bank_account.required = false : billing_method.required = false

    @user = vendor.users.first
    @user.attributes = params[:user]
    @role = vendor.roles.where(:user_id => @user.id).first
    @role.attributes = params[:role]

    if vendor.save && @location.save && pos_account.save && @role.save && @user.save
      @role.update_attributes(:active => true) # TODO fixme.. this is bad logic
      
      #now we send the new vendor user their personal account login info 
      @user.send_welcome_email
      
      redirect_to vendor_signupthankyou_path
    else
      @tag_ids = params[:location][:tag_ids].collect { |id| id.to_i }
      retrieve_tags
      render 'registration'
    end
  end

  private

  def retrieve_tags
    @tags = Tag.standard
    @extra_tags = Tag.extra
  end

end

class Dashboard::ContractorRolesController < ApplicationController
  force_ssl
  before_filter :find_role, :except => [:index, :new, :create]
  filter_access_to [:index, :new, :create]  
  filter_access_to :all, model: Role, attribute_check: true
  
  # Public: Listing of all contractors
  #
  def index
    @roles = Role.find_all_by_roletype_id(Role::DELIVERY_CONTRACTOR)
  end

  # Public: Form to add an existing contractor or create a new one.
  #
  def new
    @role = Role.new(roletype_id: Role::DELIVERY_CONTRACTOR)
    @role.build_user
  end
  
  def show
    @user = @role.user
    logger.debug @user.inspect
    
    TimeSlot::DAYS.each { |day|
      @user.delivery_hours.build(day: day) unless @user.delivery_hours.exists?(day: day)
    }
  end

  # Public: Create a new user and role.
  #
  def create
    #
    # TODO confirm privledges are not compromised
    #
    user = User.find_by_email(params[:role][:user_attributes][:email])
    params[:role].delete(:user_attributes) if user.present?

    @role = Role.new(params[:role])
    @role.user = user if user.present?

    if @role.save
      redirect_to dashboard_contractor_roles_path, notice: 'Contractor successfully added.'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    #
    # TODO confirm privledges are not compromised
    #
    
    if @role.update_attributes(params[:role])
      redirect_to dashboard_contractor_roles_path(@contractor), notice: 'Contractor successfully updated.'
    else
      render 'edit'
    end
  end
  
  def update_contractor_info
    @user = @role.user
    logger.debug @user.inspect
    respond_to do |format|
      if @user.update_attributes(params[:user])  
        format.js { render 'update_contractor_success' }
      else
        format.js { render 'update_contractor_fail' }    
      end  
    end  
  end
  

  # Public: Destroy the linking role to the vendor.
  #
  def destroy
    if @role && @role.destroy
      redirect_to dashboard_contractor_roles_path(@contractor), notice: 'User successfully removed.'
    else
      redirect_to dashboard_contractor_roles_path(@contractor)
    end
  end
  
  private
  
  def find_role
    @role = Role.find(params[:id])
  end
  
end
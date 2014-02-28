class Dashboard::LocationRolesController < ApplicationController
  before_filter :find_location
  before_filter :build_check_role
  filter_access_to :all, model: Role, attribute_check: true

  # Public: Listing of all users for location.
  #
  def index
    @roles = @location.roles.location_only # TODO change to roles
  end

  # Public: Form to add an existing user or create a new one.
  #
  def new
    @role = Role.new(location_id: @location.id)
    @role.build_user
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
    if user.present?
      if @location.users.exists?(user)
        flash.now.alert = "User already has a role at this location."
        redirect_to dashboard_location_location_roles_path(@location)
        return
      end
      @role.user = user
    end
    @role.location = @location

    if @role.save
      redirect_to dashboard_location_location_roles_path(@location), notice: 'User successfully added.'
    else
      render 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    #
    # TODO confirm privledges are not compromised
    #
    @role = Role.find(params[:id])

    if @role.update_attributes(params[:role])
      redirect_to dashboard_location_location_roles_path(@location), notice: 'User successfully updated.'
    else
      render 'edit'
    end
  end

  # Public: Destroy the linking role to the location.
  #
  def destroy
    @role = Role.find(params[:id])
    if @role && @role.destroy
      redirect_to dashboard_location_location_roles_path(@location), notice: 'User successfully removed.'
    else
      redirect_to dashboard_location_location_roles_path(@location)
    end
  end

  private

  def find_location
    @location = Location.find(params[:location_id])
  end

  def build_check_role
    @role = @location.roles.build
  end
end

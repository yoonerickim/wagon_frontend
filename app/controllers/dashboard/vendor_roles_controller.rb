class Dashboard::VendorRolesController < ApplicationController
  before_filter :find_vendor
  before_filter :build_check_role
  filter_access_to :all, model: Role, attribute_check: true

  # Public: Listing of all users for vendor.
  #
  def index
    @roles = @vendor.roles.vendor_only # TODO change to roles
  end

  # Public: Form to add an existing user or create a new one.
  #
  def new
    @role = Role.new(vendor_id: @vendor.id)
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
      if @vendor.users.exists?(user)
        flash.now.alert = "User already has a role at this vendor."
        redirect_to dashboard_vendor_vendor_roles_path(@vendor)
        return
      end
      @role.user = user
    end
    @role.vendor = @vendor

    if @role.save
      redirect_to dashboard_vendor_vendor_roles_path(@vendor), notice: 'User successfully added.'
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
      redirect_to dashboard_vendor_vendor_roles_path(@vendor), notice: 'User successfully updated.'
    else
      render 'edit'
    end
  end

  # Public: Destroy the linking role to the vendor.
  #
  def destroy
    @role = Role.find(params[:id])
    if @role && @role.destroy
      redirect_to dashboard_vendor_vendor_roles_path(@vendor), notice: 'User successfully removed.'
    else
      redirect_to dashboard_vendor_vendor_roles_path(@vendor)
    end
  end

  private

  def find_vendor
    @vendor = Vendor.find(params[:vendor_id])
  end

  def build_check_role
    @role = @vendor.roles.build
  end
end

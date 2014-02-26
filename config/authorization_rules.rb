authorization do

  role :super_user do
    has_omnipotence
  end

  role :vendor_exec do
    has_permission_on :dashboard_vendors, to: [:new, :create] do
      if_attribute :roles => intersects_with {
        user.roles.active.where(roletype_id: Role::VENDOR_EXEC)
      }
    end
    includes :vendor_admin
  end

  role :vendor_admin do
    has_permission_on :dashboard_vendors, to: :index
    has_permission_on :dashboard_vendors, to: [:edit, :update] do
      if_attribute :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      }
    end
    has_permission_on :dashboard_vendor_roles, to: [:index, :new, :create, :edit, :update, :destroy] do
      if_attribute :vendor => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      } }
    end

    has_permission_on :dashboard_locations, to: [:show, :new, :create, :edit, :update] do
      if_attribute :vendor => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      } }
    end
    has_permission_on :dashboard_location_roles, to: [:index, :new, :create, :edit, :update, :destroy] do
      if_attribute :location => { :vendor => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      } } }
    end
    has_permission_on :dashboard_menus, to: [:new, :create, :edit, :update] do
      if_attribute :location => { :vendor => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      } } }
    end
    has_permission_on :dashboard_bank_accounts, to: [:new, :create, :edit, :update] do
      if_attribute :location => { :vendor => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::VENDOR_EXEC, Role::VENDOR_ADMIN])
      } } }
    end
    has_permission_on :dashboard_locations, to: :live do
      if_attribute :vendor => { :roles => intersects_with { user.roles.active } }
    end
    has_permission_on :dashboard_orders, to: :manage_orders, join_by: :and do
      if_attribute :location => { :vendor => { :roles => intersects_with { user.roles.active } } }
      if_attribute :order_type => is_not { Order::CONTRACTOR }
    end
    includes :customer
  end

  role :location_exec do
    has_permission_on :dashboard_locations, to: [:new, :create] do
      if_attribute :roles => intersects_with {
        user.roles.active.where(roletype_id: Role::LOCATION_EXEC)
      }
    end
    includes :location_admin
  end

  role :location_admin do
    has_permission_on :dashboard_locations, to: [:show, :edit, :update] do
      if_attribute :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::LOCATION_EXEC, Role::LOCATION_ADMIN])
      }
    end
    has_permission_on :dashboard_location_roles, to: [:index, :new, :create, :edit, :update, :destroy] do
      if_attribute :location => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::LOCATION_EXEC, Role::LOCATION_ADMIN])
      } }
    end
    has_permission_on :dashboard_menus, to: [:new, :create, :edit, :update] do
      if_attribute :location => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::LOCATION_EXEC, Role::LOCATION_ADMIN])
      } }
    end
    has_permission_on :dashboard_bank_accounts, to: [:new, :create, :edit, :update] do
      if_attribute :location => { :roles => intersects_with {
        user.roles.active.where(roletype_id: [Role::LOCATION_EXEC, Role::LOCATION_ADMIN])
      } }
    end
    includes :location_delivery_staff
  end

  role :location_delivery_staff do
    includes :location_server_staff
  end

  role :location_server_staff do
    has_permission_on :dashboard_vendors, to: :index
    has_permission_on :dashboard_locations, to: :live do
      if_attribute :roles => intersects_with { user.roles.active }
    end
    has_permission_on :dashboard_orders, to: :manage_orders, join_by: :and do
      if_attribute :location => { :roles => intersects_with { user.roles.active } }
      if_attribute :order_type => is_not { Order::CONTRACTOR }
    end
    includes :customer
  end

  role :live_location do
    has_permission_on :dashboard_orders, to: :manage_orders, join_by: :and do
      if_attribute :location_id => is { user.location_id }
      if_attribute :order_type => is_not { Order::CONTRACTOR }
    end
    has_permission_on :dashboard_locations, to: :update_notifications do
      if_attribute :id => is { user.location_id }
    end
  end

  role :delivery_contractor do
    has_permission_on :dashboard_orders, to: :manage_orders do
      if_attribute :assigned_to_id => is { user.id }
    end
    has_permission_on :dashboard_contractor_roles, to: [:show, :update_contractor_info] do 
      if_attribute :user_id => is { user.id }
    end
    has_permission_on :dashboard_users, to: [:update_contractor] do
      if_attribute :id => is { user.id }
    end
  end

  role :customer do # Any authenticated user
    has_permission_on :dashboard_orders, to: [:user_cancel, :user_edit, :user_update, :user_destroy, :tip, :user_message, :user_message_send] do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on :dashboard_saved_cards, to: [:index, :new, :create, :edit, :update, :destroy] do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on :dashboard_spots, to: [:index, :new, :create, :edit, :update, :destroy] do
      # TODO not a high risk
    end
    has_permission_on :dashboard_users, to: [:edit, :update, :update_password] do
      if_attribute :id => is { user.id }
    end
    has_permission_on :dashboard_accounts, to: :show
    has_permission_on :dashboard, to: :index
    includes :guest
  end
    
end

privileges do
  privilege :manage_orders, includes: [
    :show, :edit, :update, :status, :assign, :confirm_dialog, :confirm, 
    :cancel, :assign, :confirm, :cancel, :deliver, 
    :undeliverable, :fulfill, :reauthorize, :void, :capture, :refund
  ]
end

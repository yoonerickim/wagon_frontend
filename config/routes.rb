Hitthespot::Application.routes.draw do

  #redirect to www. in production 
  constraints(:host => "hitthespot.com") do
    match "(*x)" => redirect { |params, request|
      URI.parse(request.url).tap { |x| x.host = "www.hitthespot.com" }.to_s
    }
  end

  resources :orders, only: [:edit, :update] do
    member do
      post :place
      put :submit
      get :change_card
      get :logged_in
    end
  end
  get '/orders/logged_in' => 'orders#logged_in'
  get '/checkout' => "orders#checkout", as: 'checkout_order'
  get '/thank-you' => "orders#thank_you", as: 'order_thank_you'

  mount Resque::Server, :at => '/hts0resque'

  resources :line_items, :only => [:new, :create, :edit, :update, :destroy]

  resources :users, only: [:new, :create] do
    collection do
      get 'password', :as => "forgot_password"
      post 'reset', :as => "reset_password"
      post 'check'
      post 'pin'
    end
  end

  resources :passwords, :only => [:edit, :update]
  get 'login' => 'sessions#new', :as => "login"
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy', :as => "logout"

  get '/dashboard' => "dashboard#index"
  namespace :dashboard do

    get '/communication' => "communication#index"
    post '/communication/email_check' => "communication#email_check"
    post '/communication/mass_email_go' => "communication#mass_email_go"

    resources :users, only: [:update] do
      put :update_password
      put :update_contractor
    end

    resource :account, only: [:show]
    resources :spots, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :saved_cards, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :vendors, :only => [:index, :new, :create, :edit, :update] do
      resources :vendor_roles
    end
 
    resources :contractor_roles
    put '/update_contractor_info' => 'contractor_roles#update_contractor_info'
  
    get '/live' => "live#index"
    resources :locations, :only => [:new, :create, :show, :edit, :update] do
      resources :location_roles

      member do
        get 'live'
        put :update_notifications
        post :openmenu_refresh
      end
    end

    resources :bank_accounts, only: [:new, :create, :edit, :update]
    resources :menus, only: [:new, :create, :edit, :update]

    resources :orders, only: [:show, :edit, :update] do
      get :status

      # order
      put :confirm_dialog
      put :confirm
      put :assign
      post :cancel
      post :deliver
      post :undeliverable
      post :fulfill

      # payment
      post :reauthorize
      post :capture
      post :void
      post :refund

      # user actions
      post :user_cancel
      get :user_edit
      put :user_update
      delete :user_destroy
      get :user_message
      post :user_message_send
      put :tip
    end

    resources :order_notes, only: [:create]
    
    

  end # dashboard

  resources :vendors do
    member do
      get 'registration'
      post 'register'
    end
  end

  resources :locations, :only => [] do
    member do
      get :menus
    end
    collection do
      get :fetch
    end
  end

  resources :menu_items, :only => [] do
    member do
      get 'options'
    end
  end

  get 'map' => "home#map"
  get 'owners' => "home#owners" 
  get 'couriers' => "home#couriers" 
  get 'login' => "home#login"
  get 'signup' => "users#new"
  get 'about' => "home#about"
  get 'contact' => "home#contact"
  get 'privacy' => "home#privacy"
  get 'preview_landing' => "home#preview_landing"
  get 'terms' => "home#terms"
  get 'faq' => "home#faq"
  get 'thankyou' => "home#thankyou"
  get 'vendor/signupthankyou' => 'home#signupthankyou'
  get 'mobile-about' => "home#mobile_about"  
  get 'voicemail' => "home#voicemail"  
  get 'smsreply' => "home#smsreply"  
  post 'save_email' => "home#save_email"

  get 'calls/new_call' => "calls#new_call"
  get 'calls/order_details_request_from_call' => "calls#order_details_request_from_call"  
  get 'calls/confirm_order_via_call' => "calls#confirm_order_via_call"
  post 'smsreply' => "texts#smsreply"
  get 'home' => 'home#home'
  get 'confirm_spot' => 'home#confirm_spot'
  get 'confirm_location' => 'home#confirm_location'
  get 'confirm_order' => 'orders#custom_order_checkout'
  match 'custom_order_submit' => 'orders#custom_order_submit'
  match 'send_mobile_feedback' => 'home#send_mobile_feedback'
  root :to => "home#new_home"
  
  namespace :api do
    namespace :v1 do

      resources :locations, :only => [] do
        collection do
          get :fetch
          get :contractors_available
          get :polygon_available
          get :lookup_by_google_id
        end
        member do
          get :menus
        end
      end

      resource :version, only: [] do
        get :check
      end

      resource :user, only: [:create, :update] do
        post :authenticate
        post :refresh
        post :geometry
        post :terminate
        post :clocked_in
        get :status
        get :spots
        get :saved_cards
        get :orders
        get :assigned_orders
        get :contractor_orders
      end

      resources :spots, only: [:create, :update, :destroy]
      resources :saved_cards, only: [:create, :update, :destroy]

      resources :orders, :only => [:show] do
        collection do
          post :submit
        end
        member do
          get :status
          post :capture
          post :track_user
          post :fulfill
          post :undeliverable
          post :cancel_by_location
          post :assign
          post :confirm
          post :picked_up
          post :update
          post :cancel_by_user
          post :message
        end
      end

    end # end v1
  end # end api

end



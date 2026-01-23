Rails.application.routes.draw do
  # Ensure Devise is loaded before calling devise_for so mappings are created
  begin
    require 'devise'
  rescue LoadError
    # if require fails, Devise may be unavailable; routes will still include fallback paths
  end
  devise_for :users
  root to: 'home#dashboard'
  # Devise generates session routes via `devise_for :users` above. Do not redefine them here to avoid
  # duplicate route name errors.
  resources :jewelry_items
  resources :orders, only: [:index, :show, :new, :create] do
    member do
      post :record_payment
      get :invoice
    end
  end

  get 'pos', to: 'pos#index', as: :pos
  post 'pos/charge', to: 'pos#charge', as: :pos_charge
  post 'pos/create_order', to: 'pos#create_order', as: :pos_create_order

  resources :rates, only: [:index, :new, :create, :edit, :update]
  resources :inventory_items, only: [:index, :show, :new, :create]
  resources :ledgers, only: [:index, :new]
  resources :profit_losses, only: [:index, :new]
  resources :reports, only: [:index, :new]
  get 'reports/sales_log', to: 'reports#sales_log', as: :sales_log_reports
  get 'security', to: 'security#index', as: :security_index
  get 'security/new', to: 'security#new', as: :new_security
  resources :metals, only: [:index, :new, :create, :show, :destroy]
  resources :purities, only: [:index, :new, :create, :show, :edit, :update]
    resources :customers, only: [:index, :new, :create, :show]
    resources :payments, only: [:show] do
      member do
        get :invoice
      end
    end
  resources :jewellery_categories, only: [:index, :new, :create]
  resources :stores, only: [:index, :new, :create]
  resources :metal_stocks, only: [:index, :new, :create] do
    member do
      get :adjust
      post :do_adjust
    end
  end
  resources :returns, only: [:index, :new, :create, :show]
end

Rails.application.routes.draw do
  get "meta_images/generate"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  get "meta_image", to: "meta_images#show"

  # User profile routes
  resource :profile, only: [ :show, :edit, :update ], controller: "users" do
    post "onboard_rapyd", on: :member
    # REMOVE STRIPE: onboard_stripe route no longer needed
    # post "onboard_stripe", on: :member
  end

  resources :conjectures do
    post 'add_bounty_verification', on: :member
    resources :refutations, only: [ :create, :destroy ] do
      member do
        post :accept
      end
    end
    resources :bounties, only: [ :create ]
  end

  # REMOVE STRIPE: Stripe webhook route no longer needed
  # post '/stripe/webhook', to: 'stripe_webhooks#create', defaults: { format: :json }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Removed Rapyd webhook route
  # post '/rapyd/webhook', to: 'webhooks/rapyd#receive'

  namespace :admin do
    get 'bounties/escrow', to: 'bounties#escrow', as: :bounties_escrow
    post 'bounties/:id/release', to: 'bounties#release', as: :release_bounty
    get 'dashboard', to: 'dashboard#index'
  end

  namespace :webhooks do
    # Removed Rapyd webhook route
    # post 'rapyd', to: 'rapyd#receive'
  end

  get 'docs', to: 'docs#index'

  # Defines the root path route ("/")
  root "conjectures#index"
end

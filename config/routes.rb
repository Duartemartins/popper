Rails.application.routes.draw do
  get "meta_images/generate"
  devise_for :users
  get "meta_image", to: "meta_images#show"

  # User profile routes
  resource :profile, only: [ :show, :edit, :update ], controller: "users" do
    post "claim_bounty", on: :member
  end

  resources :conjectures do
    resources :refutations, only: [ :create, :destroy ] do
      member do
        post :accept
      end
    end
    resources :bounties, only: [ :create ]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "conjectures#index"
end

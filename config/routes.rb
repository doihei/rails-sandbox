Rails.application.routes.draw do
  devise_for :users
  resources :articles do
    member do
      patch :publish # PATCH /articles/:id/publish
    end

    collection do
      get :popular
    end

    resources :comments, only: [ :create, :destroy ]
  end

  resources :tags, only: [ :index, :show ]
  resources :likes, only: [ :create ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "articles#index"
end

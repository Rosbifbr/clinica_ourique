Rails.application.routes.draw do
  root "clients#index"  # Sign-in page as the root
    get "sign_in", to: "sessions#new"
    post "sign_in", to: "sessions#create"
    get "sign_out", to: "sessions#destroy"

  resources :users
  resources :clients do
    resources :procedures
  end
  resources :procedures, except: [:index]

  post '/clients/:id/reset_odontogram', to: 'clients#reset_odontogram', as: 'reset_client_odontogram'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

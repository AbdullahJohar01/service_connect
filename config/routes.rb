Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  post "/api/v1/auth/test", to: "api/v1/auth#test"
  post "/api/v1/auth/register", to: "api/v1/auth#register"
  post "/api/v1/auth/login", to: "api/v1/auth#login"

  get "/api/v1/users/me", to: "api/v1/users#me"

  get "/api/v1/providers", to: "api/v1/providers#index"
  get "/api/v1/providers/:id", to: "api/v1/providers#show"
  get "/api/v1/providers/:id/availability", to: "api/v1/providers#availability"
end

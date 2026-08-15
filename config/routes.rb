Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
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
  get "/api/v1/providers/:id/reviews", to: "api/v1/providers#reviews"

  get "/api/v1/bookings", to: "api/v1/bookings#index"
  post "/api/v1/bookings", to: "api/v1/bookings#create"
  get "/api/v1/bookings/:id", to: "api/v1/bookings#show"

  patch "/api/v1/bookings/:id/accept", to: "api/v1/bookings#accept"
  patch "/api/v1/bookings/:id/reject", to: "api/v1/bookings#reject"
  patch "/api/v1/bookings/:id/confirm", to: "api/v1/bookings#confirm"
  patch "/api/v1/bookings/:id/start", to: "api/v1/bookings#start"
  patch "/api/v1/bookings/:id/complete", to: "api/v1/bookings#complete"
  patch "/api/v1/bookings/:id/cancel", to: "api/v1/bookings#cancel"

  get "/api/v1/reviews", to: "api/v1/reviews#index"
  get "/api/v1/reviews/:id", to: "api/v1/reviews#show"
  post "/api/v1/bookings/:booking_id/review", to: "api/v1/reviews#create"
  delete "/api/v1/reviews/:id", to: "api/v1/reviews#destroy"

  get "/api/v1/bookings/:booking_id/messages", to: "api/v1/messages#index"
  post "/api/v1/bookings/:booking_id/messages", to: "api/v1/messages#create"

  get "/api/v1/notifications", to: "api/v1/notifications#index"
  get "/api/v1/notifications/:id", to: "api/v1/notifications#show"
  patch "/api/v1/notifications/:id/read", to: "api/v1/notifications#read"
  delete "/api/v1/notifications/:id", to: "api/v1/notifications#destroy"

  # Availability API
  get "/api/v1/availabilities", to: "api/v1/availabilities#index"
  post "/api/v1/availabilities", to: "api/v1/availabilities#create"
  get "/api/v1/availabilities/:id", to: "api/v1/availabilities#show"
  patch "/api/v1/availabilities/:id", to: "api/v1/availabilities#update"
  delete "/api/v1/availabilities/:id", to: "api/v1/availabilities#destroy"

  get "/api/v1/provider-services", to: "api/v1/provider_services#index"
  post "/api/v1/provider-services", to: "api/v1/provider_services#create"
  get "/api/v1/provider-services/:id", to: "api/v1/provider_services#show"
  patch "/api/v1/provider-services/:id", to: "api/v1/provider_services#update"
  delete "/api/v1/provider-services/:id", to: "api/v1/provider_services#destroy"

  get "/api/v1/service-categories", to: "api/v1/service_categories#index"
  get "/api/v1/service-categories/:id", to: "api/v1/service_categories#show"
  post "/api/v1/service-categories", to: "api/v1/service_categories#create"
  patch "/api/v1/service-categories/:id", to: "api/v1/service_categories#update"
  delete "/api/v1/service-categories/:id", to: "api/v1/service_categories#destroy"

  get "/api/v1/addresses", to: "api/v1/addresses#index"
  get "/api/v1/addresses/:id", to: "api/v1/addresses#show"
  post "/api/v1/addresses", to: "api/v1/addresses#create"
  patch "/api/v1/addresses/:id", to: "api/v1/addresses#update"
  delete "/api/v1/addresses/:id", to: "api/v1/addresses#destroy"

  get "/api/v1/customer-profile", to: "api/v1/customer_profiles#show"
  post "/api/v1/customer-profile", to: "api/v1/customer_profiles#create"
  patch "/api/v1/customer-profile", to: "api/v1/customer_profiles#update"

  get "/api/v1/provider-profile", to: "api/v1/provider_profiles#show"
  patch "/api/v1/provider-profile", to: "api/v1/provider_profiles#update"
end

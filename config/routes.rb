Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  # ============================================================
  # WEB APPLICATION
  # ============================================================

  # Home
  root "home#index"

  # Health check
  get "/up" => "rails/health#show", as: :rails_health_check

  # ------------------------------------------------------------
  # Authentication
  # ------------------------------------------------------------

  get "/login",
      to: "sessions#new",
      as: :login

  post "/login",
       to: "sessions#create"

  delete "/logout",
         to: "sessions#destroy",
         as: :logout

  # ------------------------------------------------------------
  # Customer Dashboard
  # ------------------------------------------------------------

  get "/dashboard",
      to: "dashboard#index",
      as: :dashboard

  # ------------------------------------------------------------
  # Providers
  # ------------------------------------------------------------

  get "/providers",
      to: "providers#index",
      as: :providers

  get "/providers/:id",
      to: "providers#show",
      as: :provider

  # ------------------------------------------------------------
  # Customer Bookings
  # ------------------------------------------------------------

  resources :bookings, only: [ :index, :new, :create, :show ] do
    member do
      patch :confirm
      patch :cancel
    end
  end

  # ------------------------------------------------------------
  # Provider Dashboard
  # ------------------------------------------------------------

  get "/provider-dashboard",
      to: "provider_dashboard#index",
      as: :provider_dashboard

  patch "/provider-dashboard/bookings/:id/accept",
        to: "provider_dashboard#accept_booking",
        as: :provider_accept_booking

  patch "/provider-dashboard/bookings/:id/reject",
        to: "provider_dashboard#reject_booking",
        as: :provider_reject_booking

  patch "/provider-dashboard/bookings/:id/start",
        to: "provider_dashboard#start_booking",
        as: :provider_start_booking

  patch "/provider-dashboard/bookings/:id/complete",
        to: "provider_dashboard#complete_booking",
        as: :provider_complete_booking

  # ------------------------------------------------------------
  # Provider Profile Web Application
  # ------------------------------------------------------------

  get "/provider-profile",
      to: "provider_profile#show",
      as: :provider_profile

  get "/provider-profile/edit",
      to: "provider_profile#edit",
      as: :edit_provider_profile

  patch "/provider-profile",
        to: "provider_profile#update"

  # ------------------------------------------------------------
  # Provider Services Web Application
  # ------------------------------------------------------------

  get "/provider-services",
      to: "provider_services#index",
      as: :provider_services

  get "/provider-services/new",
      to: "provider_services#new",
      as: :new_provider_service

  post "/provider-services",
       to: "provider_services#create"

  get "/provider-services/:id/edit",
      to: "provider_services#edit",
      as: :edit_provider_service

  patch "/provider-services/:id",
        to: "provider_services#update",
        as: :provider_service

  delete "/provider-services/:id",
         to: "provider_services#destroy"

  # ------------------------------------------------------------
  # Provider Availability Web Application
  # ------------------------------------------------------------

  get "/availability",
      to: "availabilities#index",
      as: :provider_availabilities

  get "/availability/new",
      to: "availabilities#new",
      as: :new_provider_availability

  post "/availability",
       to: "availabilities#create",
       as: :create_provider_availability

  get "/availability/:id/edit",
      to: "availabilities#edit",
      as: :edit_provider_availability

  patch "/availability/:id",
        to: "availabilities#update",
        as: :provider_availability

  delete "/availability/:id",
         to: "availabilities#destroy",
         as: :delete_provider_availability

  # ------------------------------------------------------------
  # Admin Web Application
  # ------------------------------------------------------------

  namespace :admin do
    get "dashboard",
        to: "dashboard#index"

    patch "providers/:id/approve",
          to: "dashboard#approve_provider",
          as: :approve_provider

    patch "providers/:id/reject",
          to: "dashboard#reject_provider",
          as: :reject_provider
  end

  # ============================================================
  # API V1
  # ============================================================

  # ------------------------------------------------------------
  # Authentication API
  # ------------------------------------------------------------

  post "/api/v1/auth/test",
       to: "api/v1/auth#test"

  post "/api/v1/auth/register",
       to: "api/v1/auth#register"

  post "/api/v1/auth/login",
       to: "api/v1/auth#login"

  post "/api/v1/auth/refresh",
       to: "api/v1/auth#refresh"

  post "/api/v1/auth/logout",
       to: "api/v1/auth#logout"

  get "/api/v1/auth/me",
      to: "api/v1/users#me"

  post "/api/v1/auth/forgot-password",
       to: "api/v1/auth#forgot_password"

  post "/api/v1/auth/reset-password",
       to: "api/v1/auth#reset_password"

  # ------------------------------------------------------------
  # User API
  # ------------------------------------------------------------

  get "/api/v1/users/me",
      to: "api/v1/users#me"

  # ------------------------------------------------------------
  # Provider API
  # ------------------------------------------------------------

  get "/api/v1/providers",
      to: "api/v1/providers#index"

  get "/api/v1/providers/:id",
      to: "api/v1/providers#show"

  get "/api/v1/providers/:id/availability",
      to: "api/v1/providers#availability"

  get "/api/v1/providers/:id/reviews",
      to: "api/v1/providers#reviews"

  # ------------------------------------------------------------
  # Booking API
  # ------------------------------------------------------------

  get "/api/v1/bookings",
      to: "api/v1/bookings#index"

  post "/api/v1/bookings",
       to: "api/v1/bookings#create"

  get "/api/v1/bookings/:id",
      to: "api/v1/bookings#show"

  patch "/api/v1/bookings/:id/accept",
        to: "api/v1/bookings#accept"

  patch "/api/v1/bookings/:id/reject",
        to: "api/v1/bookings#reject"

  patch "/api/v1/bookings/:id/confirm",
        to: "api/v1/bookings#confirm"

  patch "/api/v1/bookings/:id/start",
        to: "api/v1/bookings#start"

  patch "/api/v1/bookings/:id/complete",
        to: "api/v1/bookings#complete"

  patch "/api/v1/bookings/:id/cancel",
        to: "api/v1/bookings#cancel"

  # ------------------------------------------------------------
  # Review API
  # ------------------------------------------------------------

  get "/api/v1/reviews",
      to: "api/v1/reviews#index"

  get "/api/v1/reviews/:id",
      to: "api/v1/reviews#show"

  post "/api/v1/bookings/:booking_id/review",
       to: "api/v1/reviews#create"

  delete "/api/v1/reviews/:id",
         to: "api/v1/reviews#destroy"

  # ------------------------------------------------------------
  # Message API
  # ------------------------------------------------------------

  get "/api/v1/bookings/:booking_id/messages",
      to: "api/v1/messages#index"

  post "/api/v1/bookings/:booking_id/messages",
       to: "api/v1/messages#create"

  # ------------------------------------------------------------
  # Notification API
  # ------------------------------------------------------------

  get "/api/v1/notifications",
      to: "api/v1/notifications#index"

  get "/api/v1/notifications/:id",
      to: "api/v1/notifications#show"

  patch "/api/v1/notifications/read_all",
        to: "api/v1/notifications#read_all"

  patch "/api/v1/notifications/:id/read",
        to: "api/v1/notifications#read"

  delete "/api/v1/notifications/:id",
         to: "api/v1/notifications#destroy"


  # ------------------------------------------------------------
  # Availability API
  # ------------------------------------------------------------

  get "/api/v1/availabilities",
      to: "api/v1/availabilities#index"

  post "/api/v1/availabilities",
       to: "api/v1/availabilities#create"

  get "/api/v1/availabilities/:id",
      to: "api/v1/availabilities#show"

  patch "/api/v1/availabilities/:id",
        to: "api/v1/availabilities#update"

  delete "/api/v1/availabilities/:id",
         to: "api/v1/availabilities#destroy"

  # ------------------------------------------------------------
  # Provider Services API
  # ------------------------------------------------------------

  get "/api/v1/provider-services",
      to: "api/v1/provider_services#index"

  post "/api/v1/provider-services",
       to: "api/v1/provider_services#create"

  get "/api/v1/provider-services/:id",
      to: "api/v1/provider_services#show"

  patch "/api/v1/provider-services/:id",
        to: "api/v1/provider_services#update"

  delete "/api/v1/provider-services/:id",
         to: "api/v1/provider_services#destroy"

  # ------------------------------------------------------------
  # Service Categories API
  # ------------------------------------------------------------

  get "/api/v1/service-categories",
      to: "api/v1/service_categories#index"

  get "/api/v1/service-categories/:id",
      to: "api/v1/service_categories#show"

  post "/api/v1/service-categories",
       to: "api/v1/service_categories#create"

  patch "/api/v1/service-categories/:id",
        to: "api/v1/service_categories#update"

  delete "/api/v1/service-categories/:id",
         to: "api/v1/service_categories#destroy"

  # ------------------------------------------------------------
  # Address API
  # ------------------------------------------------------------

  get "/api/v1/addresses",
      to: "api/v1/addresses#index"

  get "/api/v1/addresses/:id",
      to: "api/v1/addresses#show"

  post "/api/v1/addresses",
       to: "api/v1/addresses#create"

  patch "/api/v1/addresses/:id",
        to: "api/v1/addresses#update"

  delete "/api/v1/addresses/:id",
         to: "api/v1/addresses#destroy"

  # ------------------------------------------------------------
  # Customer Profile API
  # ------------------------------------------------------------

  get "/api/v1/customer-profile",
      to: "api/v1/customer_profiles#show"

  post "/api/v1/customer-profile",
       to: "api/v1/customer_profiles#create"

  patch "/api/v1/customer-profile",
        to: "api/v1/customer_profiles#update"

  # ------------------------------------------------------------
  # Provider Profile API
  # ------------------------------------------------------------

  get "/api/v1/provider-profile",
      to: "api/v1/provider_profiles#show"

  patch "/api/v1/provider-profile",
        to: "api/v1/provider_profiles#update"

  # ------------------------------------------------------------
  # Provider Profile Image API
  # ------------------------------------------------------------

  post "/api/v1/provider-profile/image",
       to: "api/v1/provider_profile_images#create"

  delete "/api/v1/provider-profile/image",
         to: "api/v1/provider_profile_images#destroy"
end

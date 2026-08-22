# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # ============================================================
    # Current User
    # ============================================================

    field :current_user, Types::UserType, null: true

    def current_user
      context[:current_user]
    end

    # ============================================================
    # Customer Profile
    # ============================================================

    field :customer_profile, Types::CustomerProfileType, null: true

    def customer_profile
      user = context[:current_user]
      return nil unless user
      return nil unless user.customer?

      user.customer_profile
    end

    # ============================================================
    # Provider Profile
    # ============================================================

    field :provider_profile, Types::ProviderProfileType, null: true

    def provider_profile
      user = context[:current_user]
      return nil unless user
      return nil unless user.provider?

      user.provider_profile
    end

    # ============================================================
    # Addresses
    # ============================================================

    field :addresses, [ Types::AddressType ], null: false

    def addresses
      user = context[:current_user]
      return [] unless user

      user.addresses
    end

    # ============================================================
    # Provider Services
    # ============================================================

    field :provider_services, [ Types::ProviderServiceType ], null: false

    def provider_services
      user = context[:current_user]

      if user&.provider?
        user.provider_profile&.provider_services || []
      else
        ProviderService.where(active: true)
      end
    end

    # ============================================================
    # Availabilities
    # ============================================================

    field :availabilities, [ Types::AvailabilityType ], null: false

    def availabilities
      user = context[:current_user]

      if user&.provider?
        user.provider_profile&.availabilities || []
      else
        Availability.where(active: true)
      end
    end

    # ============================================================
    # Service Categories
    # ============================================================

    field :service_categories, [ Types::ServiceCategoryType ], null: false

    def service_categories
      ServiceCategory.all
    end

    # ============================================================
    # Providers
    # ============================================================

    field :providers, [ Types::ProviderProfileType ], null: false do
      argument :service_category_id, ID, required: false
    end

    def providers(service_category_id: nil)
      providers = ProviderProfile.where(approval_status: :approved)

      if service_category_id.present?
        providers = providers.joins(:provider_services)
                             .where(
                               provider_services: {
                                 service_category_id: service_category_id,
                                 active: true
                               }
                             )
                             .distinct
      end

      providers
    end

    # ============================================================
    # Single Provider
    # ============================================================

    field :provider, Types::ProviderProfileType, null: true do
      argument :id, ID, required: true
    end

    def provider(id:)
      ProviderProfile.approved.find_by(id: id)
    end

    # ============================================================
    # Bookings
    # ============================================================

    field :bookings, [ Types::BookingType ], null: false

    def bookings
      user = context[:current_user]
      return [] unless user

      if user.customer?
        Booking.where(customer: user)
      elsif user.provider?
        Booking.where(provider: user.provider_profile)
      elsif user.admin?
        Booking.all
      else
        []
      end
    end

    # ============================================================
    # Single Booking
    # ============================================================

    field :booking, Types::BookingType, null: true do
      argument :id, ID, required: true
    end

    def booking(id:)
      user = context[:current_user]
      return nil unless user

      booking = Booking.find_by(id: id)
      return nil unless booking

      return booking if user.admin?

      if user.customer?
        return booking if booking.customer_id == user.id
      elsif user.provider?
        return booking if booking.provider_id == user.provider_profile&.id
      end

      nil
    end

    # ============================================================
    # Messages
    # ============================================================

    field :messages, [ Types::MessageType ], null: false do
      argument :booking_id, ID, required: true
    end

    def messages(booking_id:)
      user = context[:current_user]
      return [] unless user

      booking = Booking.find_by(id: booking_id)
      return [] unless booking

      return booking.messages if user.admin?

      if user.customer? && booking.customer_id == user.id
        return booking.messages
      end

      if user.provider? &&
         booking.provider_id == user.provider_profile&.id
        return booking.messages
      end

      []
    end

    # ============================================================
    # Notifications
    # ============================================================

    field :notifications, [ Types::NotificationType ], null: false

    def notifications
      user = context[:current_user]
      return [] unless user

      user.notifications.order(created_at: :desc)
    end

    # ============================================================
    # Reviews
    # ============================================================

    field :reviews, [ Types::ReviewType ], null: false

    def reviews
      Review.all
    end

    field :admin_dashboard, Types::DashboardType, null: true

    def admin_dashboard
      return nil unless context[:current_user]&.admin?
      bookings = Booking.all
      { total_customers: User.customer.count, total_providers: User.provider.count, pending_provider_approvals: ProviderProfile.pending.count, total_bookings: bookings.count, completed_bookings: bookings.completed.count, cancelled_bookings: bookings.cancelled.count, platform_revenue: bookings.completed.sum("COALESCE(final_price, estimated_price)").to_f, average_booking_value: bookings.average("COALESCE(final_price, estimated_price)").to_f }
    end

    field :provider_dashboard, Types::DashboardType, null: true

    def provider_dashboard
      user = context[:current_user]
      return nil unless user&.provider?
      bookings = user.provider_profile.bookings
      { total_customers: 0, total_providers: 0, pending_provider_approvals: 0, total_bookings: bookings.count, completed_bookings: bookings.completed.count, cancelled_bookings: bookings.cancelled.count, platform_revenue: bookings.completed.sum("COALESCE(final_price, estimated_price)").to_f, average_booking_value: bookings.average("COALESCE(final_price, estimated_price)").to_f }
    end
  end
end

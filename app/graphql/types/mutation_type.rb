# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # ============================================================
    # Booking Mutations
    # ============================================================

    field :create_booking,
          mutation: Mutations::CreateBooking

    field :accept_booking,
          mutation: Mutations::AcceptBooking

    field :reject_booking,
          mutation: Mutations::RejectBooking

    field :confirm_booking,
          mutation: Mutations::ConfirmBooking

    field :start_booking,
          mutation: Mutations::StartBooking

    field :complete_booking,
          mutation: Mutations::CompleteBooking

    field :cancel_booking,
          mutation: Mutations::CancelBooking

    # ============================================================
    # Message Mutations
    # ============================================================

    field :create_message,
          mutation: Mutations::CreateMessage

    # ============================================================
    # Review Mutations
    # ============================================================

    field :create_review,
          mutation: Mutations::CreateReview

    # ============================================================
    # Address Mutations
    # ============================================================

    field :create_address,
          mutation: Mutations::CreateAddress

    field :update_address,
          mutation: Mutations::UpdateAddress

    field :delete_address,
          mutation: Mutations::DeleteAddress

    # ============================================================
    # Customer Profile Mutations
    # ============================================================

    field :create_customer_profile,
          mutation: Mutations::CreateCustomerProfile

    field :update_customer_profile,
          mutation: Mutations::UpdateCustomerProfile

    # ============================================================
    # Provider Profile Mutations
    # ============================================================

    field :update_provider_profile,
          mutation: Mutations::UpdateProviderProfile

    # ============================================================
    # Provider Service Mutations
    # ============================================================

    field :create_provider_service,
          mutation: Mutations::CreateProviderService

    field :update_provider_service,
          mutation: Mutations::UpdateProviderService

    field :delete_provider_service,
          mutation: Mutations::DeleteProviderService

    # ============================================================
    # Availability Mutations
    # ============================================================

    field :create_availability,
          mutation: Mutations::CreateAvailability

    field :update_availability,
          mutation: Mutations::UpdateAvailability

    field :delete_availability,
          mutation: Mutations::DeleteAvailability

    # ============================================================
    # Notification Mutations
    # ============================================================

    field :mark_notification_read,
          mutation: Mutations::MarkNotificationRead

    field :mark_all_notifications_read,
          mutation: Mutations::MarkAllNotificationsRead

    field :approve_provider, mutation: Mutations::ApproveProvider
    field :suspend_user, mutation: Mutations::SuspendUser
  end
end

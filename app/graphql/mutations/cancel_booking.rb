# frozen_string_literal: true

module Mutations
  class CancelBooking < BaseMutation
    argument :id, ID, required: true
    argument :cancellation_reason, String, required: false

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:, cancellation_reason: nil)
      booking = accessible_booking!(id)

      booking = change_booking_status!(
        booking,
        "cancelled",
        cancellation_reason
      )

      {
        message: "Booking cancelled successfully",
        booking: booking
      }
    end
  end
end

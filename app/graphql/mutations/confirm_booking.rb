# frozen_string_literal: true

module Mutations
  class ConfirmBooking < BaseMutation
    argument :id, ID, required: true

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:)
      require_customer!

      booking = accessible_booking!(id)
      booking = change_booking_status!(booking, "confirmed")

      {
        message: "Booking confirmed successfully",
        booking: booking
      }
    end
  end
end

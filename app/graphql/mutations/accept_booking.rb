# frozen_string_literal: true

module Mutations
  class AcceptBooking < BaseMutation
    argument :id, ID, required: true

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:)
      require_provider!

      booking = accessible_booking!(id)

      booking = change_booking_status!(booking, "accepted")

      {
        message: "Booking accepted successfully",
        booking: booking
      }
    end
  end
end

# frozen_string_literal: true

module Mutations
  class StartBooking < BaseMutation
    argument :id, ID, required: true

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:)
      require_provider!

      booking = accessible_booking!(id)
      booking = change_booking_status!(booking, "in_progress")

      {
        message: "Booking started successfully",
        booking: booking
      }
    end
  end
end

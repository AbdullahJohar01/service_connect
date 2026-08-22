# frozen_string_literal: true

module Mutations
  class RejectBooking < BaseMutation
    argument :id, ID, required: true
    argument :notes, String, required: false

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:, notes: nil)
      require_provider!

      booking = accessible_booking!(id)
      booking = change_booking_status!(booking, "rejected", notes)

      {
        message: "Booking rejected successfully",
        booking: booking
      }
    end
  end
end

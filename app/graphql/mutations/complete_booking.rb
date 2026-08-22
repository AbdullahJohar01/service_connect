# frozen_string_literal: true

module Mutations
  class CompleteBooking < BaseMutation
    argument :id, ID, required: true
    argument :final_price, Float, required: false
    argument :provider_notes, String, required: false

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(id:, final_price: nil, provider_notes: nil)
      require_provider!

      booking = accessible_booking!(id)

      completion_attributes = {}

      completion_attributes[:final_price] = final_price unless final_price.nil?
      completion_attributes[:provider_notes] = provider_notes unless provider_notes.nil?

      unless completion_attributes.empty?
        unless booking.update(completion_attributes)
          raise GraphQL::ExecutionError,
                booking.errors.full_messages.join(", ")
        end
      end

      booking = change_booking_status!(booking, "completed")

      {
        message: "Booking completed successfully",
        booking: booking
      }
    end
  end
end

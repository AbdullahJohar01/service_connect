# frozen_string_literal: true

module Mutations
  class CreateBooking < BaseMutation
    description "Create a new service booking"

    argument :provider_id, ID, required: true
    argument :service_category_id, ID, required: true
    argument :address_id, ID, required: true
    argument :scheduled_at, GraphQL::Types::ISO8601DateTime, required: true
    argument :estimated_duration, Integer, required: true
    argument :customer_description, String, required: true
    argument :estimated_price, Float, required: true

    field :booking, Types::BookingType, null: false
    field :message, String, null: false

    def resolve(
      provider_id:,
      service_category_id:,
      address_id:,
      scheduled_at:,
      estimated_duration:,
      customer_description:,
      estimated_price:
    )
      require_customer!

      provider = ProviderProfile.find_by(id: provider_id)

      unless provider&.approved?
        raise GraphQL::ExecutionError, "Provider not found"
      end

      booking = Booking.new(
        provider: provider,
        service_category_id: service_category_id,
        address_id: address_id,
        scheduled_at: scheduled_at,
        estimated_duration: estimated_duration,
        customer_description: customer_description,
        estimated_price: estimated_price,
        customer: current_user,
        status: :pending
      )

      unless booking.save
        raise GraphQL::ExecutionError,
              booking.errors.full_messages.join(", ")
      end

      {
        message: "Booking created successfully",
        booking: booking
      }
    end
  end
end

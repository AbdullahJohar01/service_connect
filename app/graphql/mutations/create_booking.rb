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

      booking = Bookings::Create.new(customer: current_user, attributes: {
        provider_id: provider_id,
        service_category_id: service_category_id,
        address_id: address_id,
        scheduled_at: scheduled_at,
        estimated_duration: estimated_duration,
        customer_description: customer_description,
        estimated_price: estimated_price
      }).call

      {
        message: "Booking created successfully",
        booking: booking
      }
    rescue ActiveRecord::RecordInvalid => e
      raise GraphQL::ExecutionError, e.record.errors.full_messages.join(", ")
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end

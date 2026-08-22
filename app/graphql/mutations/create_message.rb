# frozen_string_literal: true

module Mutations
  class CreateMessage < BaseMutation
    description "Send a message for a booking"

    argument :booking_id, ID, required: true
    argument :content, String, required: true

    field :message, Types::MessageType, null: false
    field :response_message, String, null: false

    def resolve(booking_id:, content:)
      require_user!

      booking = accessible_booking!(booking_id)

      message = booking.messages.new(
        content: content,
        sender: current_user
      )

      unless message.save
        raise GraphQL::ExecutionError,
              message.errors.full_messages.join(", ")
      end

      {
        response_message: "Message sent successfully",
        message: message
      }
    end
  end
end

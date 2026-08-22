# frozen_string_literal: true

module Mutations
  class CreateReview < BaseMutation
    description "Create a review for a completed booking"

    argument :booking_id, ID, required: true
    argument :rating, Integer, required: true
    argument :comment, String, required: true

    field :review, Types::ReviewType, null: false
    field :message, String, null: false

    def resolve(booking_id:, rating:, comment:)
      require_customer!

      booking = Booking.find_by(id: booking_id)

      raise GraphQL::ExecutionError, "Booking not found" unless booking

      unless booking.customer == current_user
        raise GraphQL::ExecutionError,
              "You cannot review this booking"
      end

      unless booking.completed?
        raise GraphQL::ExecutionError,
              "Booking must be completed before reviewing"
      end

      if booking.review.present?
        raise GraphQL::ExecutionError,
              "This booking has already been reviewed"
      end

      review = Review.new(
        customer: current_user,
        provider: booking.provider,
        booking: booking,
        rating: rating,
        comment: comment
      )

      unless review.save
        raise GraphQL::ExecutionError,
              review.errors.full_messages.join(", ")
      end

      provider = booking.provider

      provider.update(
        average_rating: provider.reviews.average(:rating) || 0,
        total_reviews: provider.reviews.count
      )

      {
        message: "Review created successfully",
        review: review
      }
    end
  end
end

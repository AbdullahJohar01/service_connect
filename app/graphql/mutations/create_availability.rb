# frozen_string_literal: true

module Mutations
  class CreateAvailability < BaseMutation
    description "Create availability for the current provider"

    field :availability, Types::AvailabilityType, null: true
    field :errors, [ String ], null: false

    argument :day_of_week, Integer, required: true
    argument :start_time, String, required: true
    argument :end_time, String, required: true
    argument :active, Boolean, required: false

    def resolve(
      day_of_week:,
      start_time:,
      end_time:,
      active: nil
    )
      user = require_provider
      profile = user.provider_profile

      unless profile
        return {
          availability: nil,
          errors: [ "Provider profile not found" ]
        }
      end

      availability = profile.availabilities.new(
        day_of_week: day_of_week,
        start_time: start_time,
        end_time: end_time,
        active: active.nil? ? true : active
      )

      if availability.save
        {
          availability: availability,
          errors: []
        }
      else
        {
          availability: nil,
          errors: availability.errors.full_messages
        }
      end
    end

    private

    def require_provider
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user
      raise GraphQL::ExecutionError, "Provider access required" unless user.provider?

      user
    end
  end
end

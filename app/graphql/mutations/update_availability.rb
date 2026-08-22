# frozen_string_literal: true

module Mutations
  class UpdateAvailability < BaseMutation
    description "Update availability belonging to the current provider"

    field :availability, Types::AvailabilityType, null: true
    field :errors, [ String ], null: false

    argument :id, ID, required: true
    argument :day_of_week, Integer, required: false
    argument :start_time, String, required: false
    argument :end_time, String, required: false
    argument :active, Boolean, required: false

    def resolve(id:, **attributes)
      user = require_provider
      profile = user.provider_profile

      unless profile
        return {
          availability: nil,
          errors: [ "Provider profile not found" ]
        }
      end

      availability = profile.availabilities.find_by(id: id)

      unless availability
        return {
          availability: nil,
          errors: [ "Availability not found" ]
        }
      end

      attributes = attributes.compact

      if availability.update(attributes)
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

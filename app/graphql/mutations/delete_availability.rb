# frozen_string_literal: true

module Mutations
  class DeleteAvailability < BaseMutation
    description "Delete availability belonging to the current provider"

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    argument :id, ID, required: true

    def resolve(id:)
      user = require_provider
      profile = user.provider_profile

      unless profile
        return {
          success: false,
          errors: [ "Provider profile not found" ]
        }
      end

      availability = profile.availabilities.find_by(id: id)

      unless availability
        return {
          success: false,
          errors: [ "Availability not found" ]
        }
      end

      if availability.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
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

# frozen_string_literal: true

module Mutations
  class DeleteProviderService < BaseMutation
    description "Delete a service belonging to the current provider"

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

      service = profile.provider_services.find_by(id: id)

      unless service
        return {
          success: false,
          errors: [ "Provider service not found" ]
        }
      end

      if service.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: service.errors.full_messages
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

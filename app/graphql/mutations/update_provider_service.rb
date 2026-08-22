# frozen_string_literal: true

module Mutations
  class UpdateProviderService < BaseMutation
    description "Update a service belonging to the current provider"

    field :provider_service, Types::ProviderServiceType, null: true
    field :errors, [ String ], null: false

    argument :id, ID, required: true
    argument :service_category_id, ID, required: false
    argument :description, String, required: false
    argument :base_price, Float, required: false
    argument :duration_minutes, Integer, required: false
    argument :active, Boolean, required: false

    def resolve(id:, **attributes)
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user
      raise GraphQL::ExecutionError, "Provider access required" unless user.provider?

      profile = user.provider_profile

      unless profile
        return {
          provider_service: nil,
          errors: [ "Provider profile not found" ]
        }
      end

      service = profile.provider_services.find_by(id: id)

      unless service
        return {
          provider_service: nil,
          errors: [ "Provider service not found" ]
        }
      end

      attributes = attributes.compact

      if service.update(attributes)
        {
          provider_service: service,
          errors: []
        }
      else
        {
          provider_service: nil,
          errors: service.errors.full_messages
        }
      end
    end
  end
end

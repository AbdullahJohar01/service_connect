# frozen_string_literal: true

module Mutations
  class CreateProviderService < BaseMutation
    description "Create a service for the current provider"

    field :provider_service, Types::ProviderServiceType, null: true
    field :errors, [ String ], null: false

    argument :service_category_id, ID, required: true
    argument :description, String, required: false
    argument :base_price, Float, required: true
    argument :duration_minutes, Integer, required: true
    argument :active, Boolean, required: false

    def resolve(
      service_category_id:,
      base_price:,
      duration_minutes:,
      description: nil,
      active: nil
    )
      user = require_provider
      profile = user.provider_profile

      unless profile
        return {
          provider_service: nil,
          errors: [ "Provider profile not found" ]
        }
      end

      service = profile.provider_services.new(
        service_category_id: service_category_id,
        description: description,
        base_price: base_price,
        duration_minutes: duration_minutes,
        active: active.nil? ? true : active
      )

      if service.save
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

    private

    def require_provider
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user
      raise GraphQL::ExecutionError, "Provider access required" unless user.provider?

      user
    end
  end
end

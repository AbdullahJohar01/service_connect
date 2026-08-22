# frozen_string_literal: true

module Mutations
  class UpdateProviderProfile < BaseMutation
    description "Update the current provider's profile"

    field :provider_profile, Types::ProviderProfileType, null: true
    field :errors, [ String ], null: false

    argument :business_name, String, required: false
    argument :description, String, required: false
    argument :experience_years, Integer, required: false
    argument :hourly_rate, Float, required: false

    def resolve(
      business_name: nil,
      description: nil,
      experience_years: nil,
      hourly_rate: nil
    )
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user
      raise GraphQL::ExecutionError, "Provider access required" unless user.provider?

      profile = user.provider_profile

      unless profile
        return {
          provider_profile: nil,
          errors: [ "Provider profile not found" ]
        }
      end

      attributes = {
        business_name: business_name,
        description: description,
        experience_years: experience_years,
        hourly_rate: hourly_rate
      }.compact

      if profile.update(attributes)
        {
          provider_profile: profile,
          errors: []
        }
      else
        {
          provider_profile: nil,
          errors: profile.errors.full_messages
        }
      end
    end
  end
end

# frozen_string_literal: true

module Mutations
  class UpdateCustomerProfile < BaseMutation
    description "Update the current customer's profile"

    field :customer_profile, Types::CustomerProfileType, null: true
    field :errors, [ String ], null: false

    argument :date_of_birth, GraphQL::Types::ISO8601Date, required: false
    argument :preferred_language, String, required: false

    def resolve(date_of_birth: nil, preferred_language: nil)
      user = require_customer
      profile = user.customer_profile

      unless profile
        return {
          customer_profile: nil,
          errors: [ "Customer profile not found" ]
        }
      end

      attributes = {
        date_of_birth: date_of_birth,
        preferred_language: preferred_language
      }.compact

      if profile.update(attributes)
        {
          customer_profile: profile,
          errors: []
        }
      else
        {
          customer_profile: nil,
          errors: profile.errors.full_messages
        }
      end
    end

    private

    def require_customer
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user
      raise GraphQL::ExecutionError, "Customer access required" unless user.customer?

      user
    end
  end
end

# frozen_string_literal: true

module Mutations
  class CreateAddress < BaseMutation
    description "Create an address for the current user"

    field :address, Types::AddressType, null: true
    field :errors, [ String ], null: false

    argument :label, String, required: false
    argument :street, String, required: true
    argument :city, String, required: true
    argument :postal_code, String, required: false
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :is_default, Boolean, required: false

    def resolve(
      street:,
      city:,
      label: nil,
      postal_code: nil,
      latitude: nil,
      longitude: nil,
      is_default: nil
    )
      user = require_authenticated_user

      address = user.addresses.new(
        label: label,
        street: street,
        city: city,
        postal_code: postal_code,
        latitude: latitude,
        longitude: longitude,
        is_default: is_default
      )

      if address.save
        {
          address: address,
          errors: []
        }
      else
        {
          address: nil,
          errors: address.errors.full_messages
        }
      end
    end

    private

    def require_authenticated_user
      user = context[:current_user]

      raise GraphQL::ExecutionError, "Authentication required" unless user

      user
    end
  end
end

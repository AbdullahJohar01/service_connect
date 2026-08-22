# frozen_string_literal: true

module Mutations
  class UpdateAddress < BaseMutation
    description "Update an address belonging to the current user"

    field :address, Types::AddressType, null: true
    field :errors, [ String ], null: false

    argument :id, ID, required: true
    argument :label, String, required: false
    argument :street, String, required: false
    argument :city, String, required: false
    argument :postal_code, String, required: false
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :is_default, Boolean, required: false

    def resolve(id:, **attributes)
      user = require_authenticated_user

      address = user.addresses.find_by(id: id)

      unless address
        return {
          address: nil,
          errors: [ "Address not found" ]
        }
      end

      attributes = attributes.compact

      if address.update(attributes)
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

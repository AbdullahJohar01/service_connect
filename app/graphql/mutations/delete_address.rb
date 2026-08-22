# frozen_string_literal: true

module Mutations
  class DeleteAddress < BaseMutation
    description "Delete an address belonging to the current user"

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    argument :id, ID, required: true

    def resolve(id:)
      user = require_authenticated_user

      address = user.addresses.find_by(id: id)

      unless address
        return {
          success: false,
          errors: [ "Address not found" ]
        }
      end

      if address.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
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

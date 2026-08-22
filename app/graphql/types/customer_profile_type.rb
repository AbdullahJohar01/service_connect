# frozen_string_literal: true

module Types
  class CustomerProfileType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :date_of_birth, GraphQL::Types::ISO8601Date, null: true
    field :preferred_language, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

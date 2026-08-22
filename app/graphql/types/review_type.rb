# frozen_string_literal: true

module Types
  class ReviewType < Types::BaseObject
    field :id, ID, null: false
    field :customer_id, ID, null: false
    field :provider_id, ID, null: false
    field :booking_id, ID, null: false
    field :rating, Integer, null: false
    field :comment, String, null: false
    field :customer, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

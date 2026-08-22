# frozen_string_literal: true

module Types
  class BookingType < Types::BaseObject
    field :id, ID, null: false

    field :customer_id, ID, null: false
    field :provider_id, ID, null: false
    field :service_category_id, ID, null: false
    field :address_id, ID, null: false

    field :scheduled_at, GraphQL::Types::ISO8601DateTime, null: false
    field :estimated_duration, Integer, null: false

    field :customer_description, String, null: false
    field :provider_notes, String, null: true

    field :status, String, null: false

    field :estimated_price, Float, null: false
    field :final_price, Float, null: true

    field :cancellation_reason, String, null: true

    field :accepted_at, GraphQL::Types::ISO8601DateTime, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :cancelled_at, GraphQL::Types::ISO8601DateTime, null: true

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

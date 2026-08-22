# frozen_string_literal: true

module Types
  class ProviderServiceType < Types::BaseObject
    field :id, ID, null: false
    field :provider_profile_id, ID, null: false
    field :service_category_id, ID, null: false
    field :description, String, null: true
    field :base_price, Float, null: false
    field :duration_minutes, Integer, null: false
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

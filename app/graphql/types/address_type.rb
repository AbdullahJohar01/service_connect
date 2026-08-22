# frozen_string_literal: true

module Types
  class AddressType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :label, String, null: true
    field :street, String, null: true
    field :city, String, null: true
    field :postal_code, String, null: true
    field :latitude, Float, null: true
    field :longitude, Float, null: true
    field :is_default, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

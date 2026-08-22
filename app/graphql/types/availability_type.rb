# frozen_string_literal: true

module Types
  class AvailabilityType < Types::BaseObject
    field :id, ID, null: false
    field :provider_profile_id, ID, null: false
    field :day_of_week, Integer, null: false
    field :start_time, String, null: false
    field :end_time, String, null: false
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def start_time
      object.start_time&.strftime("%H:%M")
    end

    def end_time
      object.end_time&.strftime("%H:%M")
    end
  end
end

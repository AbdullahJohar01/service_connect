module Types
  class BookingStatusHistoryType < Types::BaseObject
    field :id, ID, null: false
    field :previous_status, String, null: true
    field :new_status, String, null: false
    field :notes, String, null: true
    field :changed_by, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

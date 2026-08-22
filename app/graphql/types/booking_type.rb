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
    field :customer, Types::UserType, null: false
    field :provider, Types::ProviderProfileType, null: false
    field :service_category, Types::ServiceCategoryType, null: false
    field :address, Types::AddressType, null: false
    field :messages, [ Types::MessageType ], null: false
    field :review, Types::ReviewType, null: true
    field :status_histories, [ Types::BookingStatusHistoryType ], null: false

    def messages
      return [] unless participant?
      object.messages.includes(:sender).order(:created_at)
    end

    def status_histories
      return [] unless participant?
      object.status_histories.includes(:changed_by).order(:created_at)
    end

    def review
      participant? ? object.review : nil
    end

    def customer
      participant? ? object.customer : nil
    end

    def provider
      participant? ? object.provider : nil
    end

    def address
      participant? ? object.address : nil
    end

    private

    def participant?
      user = context[:current_user]
      user&.admin? || user == object.customer || (user&.provider? && user.provider_profile == object.provider)
    end
  end
end

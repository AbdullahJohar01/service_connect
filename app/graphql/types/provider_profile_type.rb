# frozen_string_literal: true

module Types
  class ProviderProfileType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :business_name, String, null: false
    field :description, String, null: true
    field :experience_years, Integer, null: true
    field :hourly_rate, Float, null: true
    field :approval_status, String, null: false
    field :average_rating, Float, null: false
    field :total_reviews, Integer, null: false

    field :profile_image_url, String, null: true

    field :user, Types::UserType, null: true
    field :services, [ Types::ProviderServiceType ], null: false

    def user
      object.user
    end

    def services
      object.provider_services.where(active: true)
    end

    def profile_image_url
      return nil unless object.profile_image.attached?

      Rails.application.routes.url_helpers.rails_blob_path(
        object.profile_image,
        only_path: true
      )
    end
  end
end

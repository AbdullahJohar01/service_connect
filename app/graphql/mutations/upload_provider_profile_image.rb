# frozen_string_literal: true

module Mutations
  class UploadProviderProfileImage < BaseMutation
    description "Upload or replace the current provider's profile image"

    argument :file, ApolloUploadServer::Upload, required: true

    field :provider_profile, Types::ProviderProfileType, null: true
    field :message, String, null: false
    field :errors, [ String ], null: false

    def resolve(file:)
      require_provider!

      provider_profile = current_user.provider_profile

      unless provider_profile
        return {
          provider_profile: nil,
          message: "Provider profile not found",
          errors: [ "Provider profile not found" ]
        }
      end

      provider_profile.profile_image.attach(file)

      if provider_profile.save
        {
          provider_profile: provider_profile,
          message: "Profile image uploaded successfully",
          errors: []
        }
      else
        {
          provider_profile: nil,
          message: "Profile image could not be uploaded",
          errors: provider_profile.errors.full_messages
        }
      end
    end
  end
end

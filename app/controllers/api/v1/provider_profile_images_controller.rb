class Api::V1::ProviderProfileImagesController < Api::V1::BaseController
  def create
    unless current_user.provider?
      render json: {
        error: "Only providers can upload a profile image"
      }, status: :forbidden
      return
    end

    provider_profile = current_user.provider_profile

    unless provider_profile
      render json: {
        error: "Provider profile not found"
      }, status: :not_found
      return
    end

    file = params[:file]

    unless file.present?
      render json: {
        error: "Profile image is required"
      }, status: :unprocessable_content
      return
    end

    provider_profile.profile_image.attach(file)

    if provider_profile.save
      render json: {
        message: "Profile image uploaded successfully",
        profile_image_url: profile_image_url(provider_profile)
      }, status: :ok
    else
      provider_profile.profile_image.purge

      render json: {
        error: "Profile image could not be uploaded",
        errors: provider_profile.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def destroy
    unless current_user.provider?
      render json: {
        error: "Only providers can delete a profile image"
      }, status: :forbidden
      return
    end

    provider_profile = current_user.provider_profile

    unless provider_profile
      render json: {
        error: "Provider profile not found"
      }, status: :not_found
      return
    end

    unless provider_profile.profile_image.attached?
      render json: {
        error: "No profile image found"
      }, status: :not_found
      return
    end

    provider_profile.profile_image.purge

    render json: {
      message: "Profile image deleted successfully"
    }, status: :ok
  end

  private

  def profile_image_url(provider_profile)
    return nil unless provider_profile.profile_image.attached?

    Rails.application.routes.url_helpers.rails_blob_path(
      provider_profile.profile_image,
      only_path: true
    )
  end
end

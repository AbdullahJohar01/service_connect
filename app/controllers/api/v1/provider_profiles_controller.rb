class Api::V1::ProviderProfilesController < Api::V1::BaseController
  before_action :set_provider_profile

  def show
    render json: { provider_profile: profile_json(@provider_profile) }
  end

  def update
    if @provider_profile.update(provider_profile_params)
      render json: {
        message: "Provider profile updated successfully",
        provider_profile: profile_json(@provider_profile)
      }
    else
      render json: { errors: @provider_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_provider_profile
    @provider_profile = current_user.provider_profile

    unless @provider_profile
      render json: { error: "Provider profile not found" }, status: :not_found
    end
  end

  def provider_profile_params
    params.require(:provider_profile).permit(
      :business_name,
      :description,
      :experience_years,
      :hourly_rate
    )
  end

  def profile_json(profile)
    {
      id: profile.id,
      user_id: profile.user_id,
      business_name: profile.business_name,
      description: profile.description,
      experience_years: profile.experience_years,
      hourly_rate: profile.hourly_rate,
      approval_status: profile.approval_status,
      average_rating: profile.average_rating,
      total_reviews: profile.total_reviews,
      created_at: profile.created_at,
      updated_at: profile.updated_at
    }
  end
end

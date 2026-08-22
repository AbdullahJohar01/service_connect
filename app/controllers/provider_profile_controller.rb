class ProviderProfileController < ApplicationController
  before_action :require_login
  before_action :require_provider
  before_action :set_provider_profile

  def show
  end

  def edit
  end

  def update
    if @provider_profile.update(provider_profile_params)
      redirect_to provider_profile_path,
                  notice: "Profile updated successfully."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def require_login
    redirect_to login_path unless user_signed_in?
  end

  def require_provider
    unless current_user.provider?
      redirect_to dashboard_path,
                  alert: "Provider access required."
    end
  end

  def set_provider_profile
    @provider_profile = current_user.provider_profile

    unless @provider_profile
      redirect_to dashboard_path,
                  alert: "Provider profile not found."
    end
  end

  def provider_profile_params
    params.require(:provider_profile).permit(
      :business_name,
      :description,
      :experience_years,
      :hourly_rate,
      :profile_image,
      identity_documents: [],
      professional_certificates: []
    )
  end
end

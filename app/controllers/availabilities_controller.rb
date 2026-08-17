class AvailabilitiesController < ApplicationController
  before_action :require_login
  before_action :require_provider
  before_action :set_provider_profile
  before_action :set_availability, only: [ :edit, :update, :destroy ]

  def index
    @availabilities = @provider_profile.availabilities.order(:day_of_week, :start_time)
  end

  def new
    @availability = @provider_profile.availabilities.build
  end

  def create
    @availability = @provider_profile.availabilities.build(availability_params)

    if @availability.save
      redirect_to provider_availabilities_path,
                  notice: "Availability created successfully."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      redirect_to provider_availabilities_path,
                  notice: "Availability updated successfully."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @availability.destroy

    redirect_to provider_availabilities_path,
                notice: "Availability deleted successfully."
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

  def set_availability
    @availability = @provider_profile.availabilities.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to provider_availabilities_path,
                alert: "Availability not found."
  end

  def availability_params
    params.require(:availability).permit(
      :day_of_week,
      :start_time,
      :end_time,
      :active
    )
  end
end

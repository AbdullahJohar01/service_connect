class AvailabilitiesController < ApplicationController
  before_action :require_login
  before_action :require_provider
  before_action :set_availability, only: [ :edit, :update, :destroy ]

  def index
    @availabilities = current_user.provider_profile.availabilities.order(:day_of_week, :start_time)
  end

  def new
    @availability = current_user.provider_profile.availabilities.new
  end

  def create
    @availability = current_user.provider_profile.availabilities.new(availability_params)

    if @availability.save
      redirect_to provider_availabilities_path,
                  notice: "Availability added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      redirect_to provider_availabilities_path,
                  notice: "Availability updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @availability.destroy

    redirect_to provider_availabilities_path,
                notice: "Availability deleted successfully."
  end

  private

  def require_provider
    unless current_user&.provider? && current_user.provider_profile.present?
      redirect_to root_path, alert: "Only providers can manage availability."
    end
  end

  def set_availability
    @availability = current_user.provider_profile.availabilities.find(params[:id])
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

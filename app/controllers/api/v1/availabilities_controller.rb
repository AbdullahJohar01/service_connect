class Api::V1::AvailabilitiesController < Api::V1::BaseController
  before_action :set_availability, only: [ :show, :update, :destroy ]

  def index
    if current_user.provider?
      availabilities = current_user.provider_profile.availabilities
    else
      availabilities = Availability.where(active: true)
    end

    render json: {
      availabilities: availabilities.map { |availability| availability_json(availability) }
    }
  end

  def show
    unless can_access_availability?(@availability)
      render json: { error: "You cannot access this availability" }, status: :forbidden
      return
    end

    render json: {
      availability: availability_json(@availability)
    }
  end

  def create
    unless current_user.provider?
      render json: { error: "Only providers can create availability" }, status: :forbidden
      return
    end

    availability = current_user.provider_profile.availabilities.new(availability_params)

    if availability.save
      render json: {
        message: "Availability created successfully",
        availability: availability_json(availability)
      }, status: :created
    else
      render json: {
        error: "Availability could not be created",
        errors: availability.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    unless current_user.provider? &&
           @availability.provider_profile == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    if @availability.update(availability_params)
      render json: {
        message: "Availability updated successfully",
        availability: availability_json(@availability)
      }
    else
      render json: {
        error: "Availability could not be updated",
        errors: @availability.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.provider? &&
           @availability.provider_profile == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    @availability.destroy

    render json: {
      message: "Availability deleted successfully"
    }
  end

  private

  def set_availability
    @availability = Availability.find_by(id: params[:id])

    return if @availability

    render json: { error: "Availability not found" }, status: :not_found
  end

  def can_access_availability?(availability)
    return true if current_user.admin?

    if current_user.provider?
      availability.provider_profile == current_user.provider_profile
    else
      availability.active?
    end
  end

  def availability_params
    params.require(:availability).permit(
      :day_of_week,
      :start_time,
      :end_time,
      :active
    )
  end

  def availability_json(availability)
    {
      id: availability.id,
      provider_profile_id: availability.provider_profile_id,
      day_of_week: availability.day_of_week,
      start_time: availability.start_time,
      end_time: availability.end_time,
      active: availability.active,
      created_at: availability.created_at,
      updated_at: availability.updated_at
    }
  end
end

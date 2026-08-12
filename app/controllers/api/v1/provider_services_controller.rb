class Api::V1::ProviderServicesController < Api::V1::BaseController
  before_action :set_provider_service, only: [ :show, :update, :destroy ]

  def index
    if current_user.provider?
      provider_services = current_user.provider_profile.provider_services
    else
      provider_services = ProviderService.where(active: true)
    end

    render json: {
      provider_services: provider_services.map { |service| provider_service_json(service) }
    }
  end

  def show
    unless can_access_provider_service?(@provider_service)
      render json: { error: "You cannot access this provider service" }, status: :forbidden
      return
    end

    render json: {
      provider_service: provider_service_json(@provider_service)
    }
  end

  def create
    unless current_user.provider?
      render json: { error: "Only providers can create services" }, status: :forbidden
      return
    end

    provider_service = current_user.provider_profile.provider_services.new(provider_service_params)

    if provider_service.save
      render json: {
        message: "Provider service created successfully",
        provider_service: provider_service_json(provider_service)
      }, status: :created
    else
      render json: {
        error: "Provider service could not be created",
        errors: provider_service.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    unless current_user.provider? &&
           @provider_service.provider_profile == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    if @provider_service.update(provider_service_params)
      render json: {
        message: "Provider service updated successfully",
        provider_service: provider_service_json(@provider_service)
      }
    else
      render json: {
        error: "Provider service could not be updated",
        errors: @provider_service.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.provider? &&
           @provider_service.provider_profile == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    @provider_service.destroy

    render json: {
      message: "Provider service deleted successfully"
    }
  end

  private

  def set_provider_service
    @provider_service = ProviderService.find_by(id: params[:id])

    return if @provider_service

    render json: { error: "Provider service not found" }, status: :not_found
  end

  def can_access_provider_service?(provider_service)
    return true if current_user.admin?

    if current_user.provider?
      provider_service.provider_profile == current_user.provider_profile
    else
      provider_service.active?
    end
  end

  def provider_service_params
    params.require(:provider_service).permit(
      :service_category_id,
      :description,
      :base_price,
      :duration_minutes,
      :active
    )
  end

  def provider_service_json(provider_service)
    {
      id: provider_service.id,
      provider_profile_id: provider_service.provider_profile_id,
      service_category_id: provider_service.service_category_id,
      description: provider_service.description,
      base_price: provider_service.base_price,
      duration_minutes: provider_service.duration_minutes,
      active: provider_service.active,
      created_at: provider_service.created_at,
      updated_at: provider_service.updated_at
    }
  end
end

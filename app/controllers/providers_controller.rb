class ProvidersController < ApplicationController
  def index
    @service_category = find_service_category
    @providers = approved_providers
  end

  def show
    @provider = ProviderProfile
      .includes(:user)
      .find_by(id: params[:id], approval_status: :approved)

    unless @provider
      redirect_to providers_path, alert: "Provider not found"
      return
    end

    @provider_services = @provider
      .provider_services
      .where(active: true)
      .includes(:service_category)
      .order(:id)

    @availabilities = @provider
      .availabilities
      .where(active: true)
      .order(:day_of_week, :start_time)

    @reviews = @provider
      .reviews
      .includes(:customer)
      .order(created_at: :desc)
      .limit(5)
  end

  private

  def find_service_category
    return if params[:service_category_id].blank?

    ServiceCategory.find_by(
      id: params[:service_category_id],
      active: true
    )
  end

  def approved_providers
    providers = ProviderProfile
      .where(approval_status: :approved)
      .includes(:user)

    if @service_category
      providers = providers
        .joins(:provider_services)
        .where(
          provider_services: {
            service_category_id: @service_category.id,
            active: true
          }
        )
        .distinct
    end

    providers.order(:business_name)
  end
end

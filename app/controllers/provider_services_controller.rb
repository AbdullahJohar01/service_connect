class ProviderServicesController < ApplicationController
  before_action :require_login
  before_action :require_provider
  before_action :set_provider_profile
  before_action :set_provider_service, only: [ :edit, :update, :destroy ]

  def index
    @provider_services = @provider_profile.provider_services.includes(:service_category)
  end

  def new
    @provider_service = @provider_profile.provider_services.build
    load_service_categories
  end

  def create
    @provider_service = @provider_profile.provider_services.build(provider_service_params)

    if @provider_service.save
      redirect_to provider_services_path,
                  notice: "Service created successfully."
    else
      load_service_categories
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def edit
    load_service_categories
  end

  def update
    if @provider_service.update(provider_service_params)
      redirect_to provider_services_path,
                  notice: "Service updated successfully."
    else
      load_service_categories
      flash.now[:alert] = "Please correct the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @provider_service.destroy

    redirect_to provider_services_path,
                notice: "Service deleted successfully."
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

  def set_provider_service
    @provider_service = @provider_profile.provider_services.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to provider_services_path,
                alert: "Service not found."
  end

  def load_service_categories
    @service_categories = ServiceCategory.where(active: true).order(:name)
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
end

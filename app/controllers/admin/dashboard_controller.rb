module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @pending_providers = ProviderProfile.where(approval_status: :pending)
        .includes(:user)
        .order(created_at: :asc)

      @approved_providers = ProviderProfile.where(approval_status: :approved)
        .includes(:user)
        .order(created_at: :asc)

      @rejected_providers = ProviderProfile.where(approval_status: :rejected)
        .includes(:user)
        .order(created_at: :asc)
    end

    def approve_provider
      provider_profile = ProviderProfile.find(params[:id])

      if provider_profile.update(approval_status: :approved)
        redirect_to admin_dashboard_path, notice: "Provider approved successfully."
      else
        redirect_to admin_dashboard_path,
          alert: "Provider could not be approved."
      end
    end

    def reject_provider
      provider_profile = ProviderProfile.find(params[:id])

      if provider_profile.update(approval_status: :rejected)
        redirect_to admin_dashboard_path, notice: "Provider rejected successfully."
      else
        redirect_to admin_dashboard_path,
          alert: "Provider could not be rejected."
      end
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to access the admin dashboard."
      end
    end
  end
end

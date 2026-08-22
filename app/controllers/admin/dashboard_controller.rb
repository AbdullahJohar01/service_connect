module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @stats = {
        customers: User.customer.count, providers: User.provider.count,
        bookings: Booking.count, completed: Booking.completed.count,
        cancelled: Booking.cancelled.count,
        revenue: Booking.completed.sum("COALESCE(final_price, estimated_price)"),
        average_booking_value: Booking.average("COALESCE(final_price, estimated_price)") || 0
      }
      @pending_providers = ProviderProfile.where(approval_status: :pending)
        .includes(:user)
        .order(created_at: :asc)

      @approved_providers = ProviderProfile.where(approval_status: :approved)
        .includes(:user)
        .order(created_at: :asc)

      @rejected_providers = ProviderProfile.where(approval_status: :rejected)
        .includes(:user)
        .order(created_at: :asc)
      @users = User.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @users ||= User.order(created_at: :desc).limit(25)
      @activity_logs = ActivityLog.includes(:actor, :subject).order(created_at: :desc).limit(20)
    end

    def approve_provider
      provider_profile = ProviderProfile.find_by(id: params[:id])
      return redirect_to(admin_dashboard_path, alert: "Provider not found.") unless provider_profile

      if provider_profile.update(approval_status: :approved)
        ActivityLogs::Record.call(action: "provider.approved", actor: current_user, subject: provider_profile)
        redirect_to admin_dashboard_path, notice: "Provider approved successfully."
      else
        redirect_to admin_dashboard_path,
          alert: "Provider could not be approved."
      end
    end

    def reject_provider
      provider_profile = ProviderProfile.find_by(id: params[:id])
      return redirect_to(admin_dashboard_path, alert: "Provider not found.") unless provider_profile

      if provider_profile.update(approval_status: :rejected, rejection_reason: params[:rejection_reason])
        ActivityLogs::Record.call(action: "provider.rejected", actor: current_user, subject: provider_profile, metadata: { reason: params[:rejection_reason] })
        redirect_to admin_dashboard_path, notice: "Provider rejected successfully."
      else
        redirect_to admin_dashboard_path,
          alert: "Provider could not be rejected."
      end
    end

    def suspend_user
      change_user_status(:suspended, "user.suspended")
    end

    def reactivate_user
      change_user_status(:active, "user.reactivated")
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to access the admin dashboard."
      end
    end

    def change_user_status(status, action)
      user = User.find_by(id: params[:id])
      return redirect_to(admin_dashboard_path, alert: "User not found.") unless user
      return redirect_to(admin_dashboard_path, alert: "You cannot change your own account status.") if user == current_user
      user.update!(status: status)
      ActivityLogs::Record.call(action: action, actor: current_user, subject: user)
      redirect_to admin_dashboard_path, notice: "User #{status}."
    end
  end
end

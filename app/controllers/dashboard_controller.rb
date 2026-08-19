class DashboardController < ApplicationController
  before_action :require_login

  def index
    @bookings = current_user
      .customer_bookings
      .includes(:provider, :service_category, :address)
      .order(created_at: :desc)
      .limit(5)

    @total_bookings = current_user.customer_bookings.count
    @pending_bookings = current_user.customer_bookings.pending.count
    @completed_bookings = current_user.customer_bookings.completed.count
  end

  private

  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in first."
    end
  end
end

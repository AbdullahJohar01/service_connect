class ProviderDashboardController < ApplicationController
  before_action :require_provider

  def index
    @provider = current_user.provider_profile

    unless @provider
      redirect_to root_path, alert: "Provider profile not found."
      return
    end

    @bookings = @provider.bookings
      .includes(:customer, :service_category, :address)
      .order(created_at: :desc)

    @pending_bookings = @provider.bookings.pending.count
    @accepted_bookings = @provider.bookings.accepted.count
    @confirmed_bookings = @provider.bookings.confirmed.count
    @completed_bookings = @provider.bookings.completed.count
    @today_bookings = @provider.bookings.where(scheduled_at: Time.zone.today.all_day).count
    @average_rating = @provider.average_rating
    @monthly_earnings = @provider.bookings.completed.where(completed_at: Time.current.beginning_of_month..Time.current.end_of_month).sum("COALESCE(final_price, estimated_price)")
    @upcoming_bookings = @provider.bookings.where(scheduled_at: Time.current..7.days.from_now).where(status: [ :accepted, :confirmed ]).order(:scheduled_at).limit(5)
  end

  def accept_booking
    change_booking_status("accepted")
  end

  def reject_booking
    change_booking_status("rejected", params[:rejection_reason])
  end

  def start_booking
    change_booking_status("in_progress")
  end

  def complete_booking
    change_booking_status("completed")
  end

  private

  def change_booking_status(new_status, notes = nil)
    booking = current_user.provider_profile.bookings.find_by(id: params[:id])

    unless booking
      redirect_to provider_dashboard_path,
                  alert: "Booking not found."
      return
    end

    Bookings::ChangeStatus.new(
      booking: booking,
      user: current_user,
      new_status: new_status,
      notes: notes
    ).call

    redirect_to provider_dashboard_path,
                notice: "Booking #{new_status.tr('_', ' ')} successfully."
  rescue StandardError => e
    redirect_to provider_dashboard_path,
                alert: e.message
  end

  def require_provider
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in first."
      return
    end

    unless current_user.provider?
      redirect_to root_path, alert: "Provider access required."
    end
  end
end

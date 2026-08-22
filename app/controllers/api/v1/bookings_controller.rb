class Api::V1::BookingsController < Api::V1::BaseController
  before_action :set_booking, only: [
    :show,
    :accept,
    :reject,
    :confirm,
    :start,
    :complete,
    :cancel
  ]

  def index
    bookings = if current_user.customer?
                 Booking.where(customer: current_user)
    elsif current_user.provider?
                 Booking.where(provider: current_user.provider_profile)
    else
                 Booking.all
    end

    bookings = apply_filters(bookings).order(safe_sort)
    page, per_page = pagination
    total_count = bookings.count
    bookings = bookings.offset((page - 1) * per_page).limit(per_page)
    render json: { bookings: bookings.map { |booking| booking_json(booking) }, pagination: { page: page, per_page: per_page, total_count: total_count, total_pages: (total_count.to_f / per_page).ceil } }
  end

  def show
    unless can_access_booking?(@booking)
      render json: {
        error: "You cannot access this booking"
      }, status: :forbidden
      return
    end

    render json: {
      booking: booking_json(@booking)
    }
  end

  def create
    unless current_user.customer?
      render json: {
        error: "Only customers can create bookings"
      }, status: :forbidden
      return
    end

    booking = Bookings::Create.new(customer: current_user, attributes: booking_params.to_h.symbolize_keys).call
    render json: { message: "Booking created successfully", booking: booking_json(booking) }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Provider or address not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Booking could not be created", errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def accept
    change_booking_status("accepted")
  end

  def reject
    change_booking_status("rejected")
  end

  def confirm
    change_booking_status("confirmed")
  end

  def start
    change_booking_status("in_progress")
  end

  def complete
    completion_params = completion_booking_params

    unless completion_params.empty?
      unless @booking.update(completion_params)
        render json: {
          error: "Booking could not be completed",
          errors: @booking.errors.full_messages
        }, status: :unprocessable_entity
        return
      end
    end

    change_booking_status("completed")
  end

  def cancel
    change_booking_status(
      "cancelled",
      params[:cancellation_reason]
    )
  end

  private

  def change_booking_status(new_status, notes = nil)
    booking = Bookings::ChangeStatus.new(
      booking: @booking,
      user: current_user,
      new_status: new_status,
      notes: notes
    ).call

    render json: {
      message: "Booking #{new_status.tr('_', ' ')} successfully",
      booking: booking_json(booking)
    }
  rescue StandardError => e
    render json: {
      error: e.message
    }, status: :unprocessable_entity
  end

  def set_booking
    @booking = Booking.find_by(id: params[:id])

    return if @booking

    render json: {
      error: "Booking not found"
    }, status: :not_found
  end

  def can_access_booking?(booking)
    return true if current_user.admin?

    if current_user.customer?
      booking.customer == current_user
    elsif current_user.provider?
      booking.provider == current_user.provider_profile
    else
      false
    end
  end

  def booking_params
    params.require(:booking).permit(
      :provider_id,
      :service_category_id,
      :address_id,
      :scheduled_at,
      :estimated_duration,
      :customer_description,
      :estimated_price,
      :final_price,
      :provider_notes
    )
  end

  def completion_booking_params
    params.fetch(:booking, {}).permit(
      :final_price,
      :provider_notes
    )
  end

  def booking_json(booking)
    {
      id: booking.id,
      customer_id: booking.customer_id,
      provider_id: booking.provider_id,
      service_category_id: booking.service_category_id,
      address_id: booking.address_id,
      scheduled_at: booking.scheduled_at,
      estimated_duration: booking.estimated_duration,
      customer_description: booking.customer_description,
      provider_notes: booking.provider_notes,
      status: booking.status,
      estimated_price: booking.estimated_price,
      final_price: booking.final_price,
      cancellation_reason: booking.cancellation_reason,
      accepted_at: booking.accepted_at,
      started_at: booking.started_at,
      completed_at: booking.completed_at,
      cancelled_at: booking.cancelled_at
    }
  end

  def apply_filters(scope)
    scope = scope.where(status: params[:status]) if params[:status].present? && Booking.statuses.key?(params[:status])
    scope = scope.where(service_category_id: params[:service_category_id]) if params[:service_category_id].present?
    scope = scope.where("scheduled_at >= ?", Time.zone.parse(params[:from])) if params[:from].present?
    scope = scope.where("scheduled_at <= ?", Time.zone.parse(params[:to]).end_of_day) if params[:to].present?
    scope
  rescue ArgumentError
    scope.none
  end

  def pagination
    page = [ Integer(params.fetch(:page, 1)), 1 ].max
    per_page = [ [ Integer(params.fetch(:per_page, 20)), 1 ].max, 100 ].min
    [ page, per_page ]
  rescue ArgumentError
    [ 1, 20 ]
  end

  def safe_sort
    field = %w[scheduled_at created_at status].include?(params[:sort]) ? params[:sort] : "scheduled_at"
    { field => params[:direction] == "asc" ? :asc : :desc }
  end
end

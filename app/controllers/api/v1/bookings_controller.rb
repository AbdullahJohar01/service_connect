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

    render json: {
      bookings: bookings.map { |booking| booking_json(booking) }
    }
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

    provider = ProviderProfile.find_by(id: booking_params[:provider_id])

    unless provider&.approved?
      render json: {
        error: "Provider not found"
      }, status: :not_found
      return
    end

    booking = Booking.new(booking_params)
    booking.customer = current_user
    booking.status = :pending

    if booking.save
      render json: {
        message: "Booking created successfully",
        booking: booking_json(booking)
      }, status: :created
    else
      render json: {
        error: "Booking could not be created",
        errors: booking.errors.full_messages
      }, status: :unprocessable_entity
    end
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
      :estimated_price
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
end

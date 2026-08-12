class Api::V1::BookingsController < Api::V1::BaseController
  before_action :set_booking, only: [ :show, :accept, :reject, :confirm, :start, :complete, :cancel ]

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
      render json: { error: "You cannot access this booking" }, status: :forbidden
      return
    end

    render json: {
      booking: booking_json(@booking)
    }
  end

  def create
    unless current_user.customer?
      render json: { error: "Only customers can create bookings" }, status: :forbidden
      return
    end

    provider = ProviderProfile.find_by(id: booking_params[:provider_id])

    unless provider&.approved?
      render json: { error: "Provider not found" }, status: :not_found
      return
    end

    booking = Booking.new(booking_params)
    booking.customer = current_user

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
    unless current_user.provider? &&
           @booking.provider == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    unless @booking.pending?
      render json: {
        error: "Booking cannot be accepted from its current status"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(
      status: :accepted,
      accepted_at: Time.current
    )
      Notification.create!(
        user: @booking.customer,
        booking: @booking,
        notification_type: "booking_accepted",
        message: "Your booking has been accepted by the provider."
      )

      render json: {
        message: "Booking accepted",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be accepted",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def reject
    unless current_user.provider? &&
           @booking.provider == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    unless @booking.pending?
      render json: {
        error: "Booking cannot be rejected from its current status"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(status: :rejected)
      Notification.create!(
        user: @booking.customer,
        booking: @booking,
        notification_type: "booking_rejected",
        message: "Your booking has been rejected by the provider."
      )

      render json: {
        message: "Booking rejected",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be rejected",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def confirm
    unless current_user.customer? &&
           @booking.customer == current_user
      render json: { error: "Customer access required" }, status: :forbidden
      return
    end

    unless @booking.accepted?
      render json: {
        error: "Booking must be accepted before it can be confirmed"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(status: :confirmed)
      Notification.create!(
        user: @booking.provider.user,
        booking: @booking,
        notification_type: "booking_confirmed",
        message: "A customer has confirmed the booking."
      )

      render json: {
        message: "Booking confirmed",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be confirmed",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def start
    unless current_user.provider? &&
           @booking.provider == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    unless @booking.confirmed?
      render json: {
        error: "Booking must be confirmed before it can start"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(
      status: :in_progress,
      started_at: Time.current
    )
      Notification.create!(
        user: @booking.customer,
        booking: @booking,
        notification_type: "booking_started",
        message: "Your booking has been started by the provider."
      )

      render json: {
        message: "Booking started",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be started",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def complete
    unless current_user.provider? &&
           @booking.provider == current_user.provider_profile
      render json: { error: "Provider access required" }, status: :forbidden
      return
    end

    unless @booking.in_progress?
      render json: {
        error: "Booking must be in progress before it can be completed"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(
      status: :completed,
      completed_at: Time.current
    )
      Notification.create!(
        user: @booking.customer,
        booking: @booking,
        notification_type: "booking_completed",
        message: "Your booking has been completed by the provider."
      )

      render json: {
        message: "Booking completed",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be completed",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def cancel
    unless current_user.customer? || current_user.provider?
      render json: { error: "Customer or provider access required" }, status: :forbidden
      return
    end

    unless @booking.customer == current_user ||
           (current_user.provider? && @booking.provider == current_user.provider_profile)
      render json: { error: "You cannot cancel this booking" }, status: :forbidden
      return
    end

    unless @booking.pending? || @booking.accepted? || @booking.confirmed?
      render json: {
        error: "Booking cannot be cancelled from its current status"
      }, status: :unprocessable_entity
      return
    end

    if @booking.update(
      status: :cancelled,
      cancellation_reason: params[:cancellation_reason],
      cancelled_at: Time.current
    )
      notification_user = if @booking.customer == current_user
                            @booking.provider.user
      else
                            @booking.customer
      end

      Notification.create!(
        user: notification_user,
        booking: @booking,
        notification_type: "booking_cancelled",
        message: "Your booking has been cancelled."
      )

      render json: {
        message: "Booking cancelled",
        booking: booking_json(@booking)
      }
    else
      render json: {
        error: "Booking could not be cancelled",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:id])

    return if @booking

    render json: { error: "Booking not found" }, status: :not_found
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

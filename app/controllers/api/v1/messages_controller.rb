class Api::V1::MessagesController < Api::V1::BaseController
  before_action :set_booking

  def index
    unless can_access_booking?
      render json: { error: "You cannot access this booking" }, status: :forbidden
      return
    end

    render json: {
      messages: @booking.messages.includes(:sender).map { |message| message_json(message) }
    }
  end

  def create
    unless can_access_booking?
      render json: { error: "You cannot access this booking" }, status: :forbidden
      return
    end

    message = @booking.messages.new(message_params)
    message.sender = current_user

    if message.save
      render json: {
        message: "Message sent successfully",
        data: message_json(message)
      }, status: :created
    else
      render json: {
        error: "Message could not be sent",
        errors: message.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:booking_id])

    return if @booking

    render json: { error: "Booking not found" }, status: :not_found
  end

  def can_access_booking?
    return true if current_user.admin?

    if current_user.customer?
      @booking.customer == current_user
    elsif current_user.provider?
      @booking.provider == current_user.provider_profile
    else
      false
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def message_json(message)
    {
      id: message.id,
      booking_id: message.booking_id,
      sender_id: message.sender_id,
      content: message.content,
      created_at: message.created_at,
      updated_at: message.updated_at
    }
  end
end

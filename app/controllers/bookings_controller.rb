class BookingsController < ApplicationController
  before_action :require_login
  before_action :require_customer
  before_action :set_booking, only: [
    :show,
    :confirm,
    :cancel,
    :create_review
  ]

  def index
    @bookings = current_user
      .customer_bookings
      .includes(:provider, :service_category, :address)
      .order(created_at: :desc)
  end

  def new
    @provider = approved_provider

    unless @provider
      redirect_to providers_path, alert: "Provider not found."
      return
    end

    @provider_services = @provider
      .provider_services
      .where(active: true)
      .includes(:service_category)
      .order(:id)

    @addresses = current_user.addresses
      .order(is_default: :desc, id: :asc)

    if @addresses.empty?
      redirect_to root_path,
                  alert: "Please add an address before booking."
      return
    end

    @booking = Booking.new(
      provider: @provider,
      customer: current_user
    )
  end

  def create
    @provider = approved_provider

    unless @provider
      redirect_to providers_path, alert: "Provider not found."
      return
    end

    @booking = current_user.customer_bookings.new(booking_params)
    @booking.provider = @provider
    @booking.status = :pending

    if @booking.save
      redirect_to booking_path(@booking),
                  notice: "Booking created successfully."
    else
      @provider_services = @provider
        .provider_services
        .where(active: true)
        .includes(:service_category)
        .order(:id)

      @addresses = current_user.addresses
        .order(is_default: :desc, id: :asc)

      flash.now[:alert] = "Please correct the booking details."

      render :new, status: :unprocessable_content
    end
  end

  def show
    @review = @booking.review || Review.new
  end

  def confirm
    change_status("confirmed")
  end

  def cancel
    change_status(
      "cancelled",
      params[:cancellation_reason]
    )
  end

  def create_review
    unless @booking.completed?
      redirect_to booking_path(@booking),
                  alert: "A review can only be submitted after the booking is completed."
      return
    end

    if @booking.review.present?
      redirect_to booking_path(@booking),
                  alert: "You have already reviewed this booking."
      return
    end

    @review = @booking.build_review(
      customer: current_user,
      provider: @booking.provider,
      rating: review_params[:rating],
      comment: review_params[:comment]
    )

    if @review.save
      redirect_to booking_path(@booking),
                  notice: "Thank you. Your review was submitted successfully."
    else
      @review = @booking.review || @review

      flash.now[:alert] = "Please correct the review details."
      render :show, status: :unprocessable_content
    end
  end

  private

  def change_status(new_status, notes = nil)
    booking = Bookings::ChangeStatus.new(
      booking: @booking,
      user: current_user,
      new_status: new_status,
      notes: notes
    ).call

    redirect_to booking_path(booking),
                notice: "Booking #{new_status.tr('_', ' ')} successfully."
  rescue StandardError => e
    redirect_to booking_path(@booking),
                alert: e.message
  end

  def approved_provider
    ProviderProfile.find_by(
      id: booking_provider_id,
      approval_status: :approved
    )
  end

  def booking_provider_id
    params[:provider_id].presence ||
      params.dig(:booking, :provider_id)
  end

  def set_booking
    @booking = current_user.customer_bookings.find_by(id: params[:id])

    unless @booking
      redirect_to bookings_path,
                  alert: "Booking not found."
    end
  end

  def require_customer
    unless current_user.customer?
      redirect_to root_path,
                  alert: "Only customers can access customer bookings."
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

  def review_params
    params.require(:review).permit(
      :rating,
      :comment
    )
  end
end

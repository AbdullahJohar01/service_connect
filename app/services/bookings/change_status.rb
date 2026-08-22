class Bookings::ChangeStatus
  VALID_TRANSITIONS = {
    "pending" => %w[accepted rejected cancelled],
    "accepted" => %w[confirmed cancelled],
    "confirmed" => %w[in_progress cancelled],
    "in_progress" => %w[completed],
    "rejected" => [],
    "completed" => [],
    "cancelled" => []
  }

  def initialize(booking:, user:, new_status:, notes: nil)
    @booking = booking
    @user = user
    @new_status = new_status.to_s
    @notes = notes
  end

  def call
    Booking.transaction do
      @booking.lock!
      validate_user!
      validate_transition!
      previous_status = @booking.status

      update_booking!(previous_status)
      create_history!(previous_status)
      create_notification!
      ActivityLogs::Record.call(action: "booking.#{@new_status}", actor: @user, subject: @booking)
      BookingNotificationJob.perform_later(@booking.id, @new_status)
      schedule_reminders! if @new_status == "accepted"
    end

    @booking
  end

  private

  def schedule_reminders!
    [ 24.hours, 1.hour ].each do |offset|
      run_at = @booking.scheduled_at - offset
      BookingReminderJob.set(wait_until: run_at).perform_later(@booking.id) if run_at > Time.current
    end
  end

  def validate_user!
    case @new_status
    when "accepted", "rejected", "in_progress", "completed"
      unless @user.provider? &&
             @booking.provider == @user.provider_profile
        raise StandardError, "Provider access required"
      end

    when "confirmed"
      unless @user.customer? &&
             @booking.customer == @user
        raise StandardError, "Customer access required"
      end

    when "cancelled"
      unless @booking.customer == @user ||
             (@user.provider? &&
              @booking.provider == @user.provider_profile)
        raise StandardError, "You cannot cancel this booking"
      end
    end
  end

  def validate_transition!
    allowed_statuses = VALID_TRANSITIONS[@booking.status]

    unless allowed_statuses&.include?(@new_status)
      raise StandardError,
            "Booking cannot be changed from #{@booking.status} to #{@new_status}"
    end
  end

  def update_booking!(previous_status)
    attributes = {
      status: @new_status
    }

    case @new_status
    when "accepted"
      attributes[:accepted_at] = Time.current
    when "in_progress"
      attributes[:started_at] = Time.current
    when "completed"
      attributes[:completed_at] = Time.current
    when "cancelled"
      attributes[:cancellation_reason] = @notes
      attributes[:cancelled_at] = Time.current
    end

    @booking.update!(attributes)
  end

  def create_history!(previous_status)
    BookingStatusHistory.create!(
      booking: @booking,
      changed_by: @user,
      previous_status: Booking.statuses[previous_status],
      new_status: Booking.statuses[@new_status],
      notes: @notes
    )
  end

  def create_notification!
    notification_user = notification_recipient

    return unless notification_user

    Notification.create!(
      user: notification_user,
      booking: @booking,
      notification_type: "booking_#{@new_status}",
      message: notification_message
    )
  end

  def notification_recipient
    case @new_status
    when "accepted", "rejected", "in_progress", "completed"
      @booking.customer
    when "confirmed"
      @booking.provider.user
    when "cancelled"
      if @booking.customer == @user
        @booking.provider.user
      else
        @booking.customer
      end
    end
  end

  def notification_message
    case @new_status
    when "accepted"
      "Your booking has been accepted by the provider."
    when "rejected"
      "Your booking has been rejected by the provider."
    when "confirmed"
      "A customer has confirmed the booking."
    when "in_progress"
      "Your booking has been started by the provider."
    when "completed"
      "Your booking has been completed by the provider."
    when "cancelled"
      "Your booking has been cancelled."
    end
  end
end

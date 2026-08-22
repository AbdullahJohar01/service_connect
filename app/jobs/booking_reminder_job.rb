class BookingReminderJob < ApplicationJob
  queue_as :default
  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking && (booking.accepted? || booking.confirmed?)
    Notification.find_or_create_by!(user: booking.customer, booking: booking, notification_type: "booking_reminder") do |notification|
      notification.message = "Reminder: your booking is scheduled for #{booking.scheduled_at.strftime('%d %b, %I:%M %p')}."
    end
  end
end

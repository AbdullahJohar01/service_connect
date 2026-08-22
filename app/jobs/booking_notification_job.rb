class BookingNotificationJob < ApplicationJob
  queue_as :default
  def perform(booking_id, event)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    recipient = event == "created" ? booking.provider.user : booking.customer
    BookingMailer.with(booking: booking, event: event, recipient: recipient).status_changed.deliver_now
  end
end

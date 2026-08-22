class Bookings::Create
  def initialize(customer:, attributes:)
    @customer = customer
    @attributes = attributes
  end

  def call
    raise ArgumentError, "Only active customers can create bookings" unless @customer.customer? && @customer.active?

    Booking.transaction do
      provider = ProviderProfile.lock.find(@attributes.fetch(:provider_id))
      raise ActiveRecord::RecordNotFound, "Provider not found" unless provider.approved? && provider.user.active?

      address = @customer.addresses.find(@attributes.fetch(:address_id))
      booking = provider.bookings.new(@attributes.merge(customer: @customer, address: address, status: :pending))
      booking.save!
      ActivityLogs::Record.call(action: "booking.created", actor: @customer, subject: booking)
      BookingNotificationJob.perform_later(booking.id, "created")
      booking
    end
  end
end

require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "booking status defaults to pending" do
    booking = Booking.new

    assert_equal "pending", booking.status
  end

  test "booking is valid when scheduled during provider availability" do
    booking = Booking.new(
      customer: users(:one),
      provider: provider_profiles(:one),
      service_category: service_categories(:one),
      address: addresses(:one),
      scheduled_at: Time.parse("2026-08-17 10:00:00 UTC"),
      estimated_duration: 60,
      customer_description: "Test booking",
      estimated_price: 1500
    )

    assert booking.valid?
    assert_empty booking.errors.full_messages
  end

  test "booking is invalid outside provider availability" do
    booking = Booking.new(
      customer: users(:one),
      provider: provider_profiles(:one),
      service_category: service_categories(:one),
      address: addresses(:one),
      scheduled_at: Time.parse("2026-08-15 10:00:00 UTC"),
      estimated_duration: 60,
      customer_description: "Test booking",
      estimated_price: 1500
    )

    assert_not booking.valid?

    assert_includes booking.errors.full_messages,
                    "Scheduled at is outside the provider's availability"
  end

  test "booking is invalid when it overlaps an existing booking" do
    existing_booking = Booking.create!(
      customer: users(:one),
      provider: provider_profiles(:one),
      service_category: service_categories(:one),
      address: addresses(:one),
      scheduled_at: Time.parse("2026-08-17 10:00:00 UTC"),
      estimated_duration: 60,
      customer_description: "Existing booking",
      estimated_price: 1500
    )

    overlapping_booking = Booking.new(
      customer: users(:one),
      provider: provider_profiles(:one),
      service_category: service_categories(:one),
      address: addresses(:one),
      scheduled_at: Time.parse("2026-08-17 10:30:00 UTC"),
      estimated_duration: 60,
      customer_description: "Overlapping booking",
      estimated_price: 1500
    )

    assert_not overlapping_booking.valid?

    assert_includes overlapping_booking.errors.full_messages,
                    "Scheduled at overlaps with an existing booking"
  end
end

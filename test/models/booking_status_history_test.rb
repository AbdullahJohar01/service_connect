require "test_helper"

class BookingStatusHistoryTest < ActiveSupport::TestCase
  test "booking status history is valid with valid attributes" do
    history = booking_status_histories(:one)

    assert history.valid?
  end

  test "booking status history belongs to a booking" do
    history = booking_status_histories(:one)

    assert_equal bookings(:one), history.booking
  end

  test "booking status history belongs to the user who changed the status" do
  history = booking_status_histories(:one)

  assert_equal users(:one), history.changed_by
end

  test "new_status is required" do
    history = booking_status_histories(:one)
    history.new_status = nil

    assert_not history.valid?
    assert_includes history.errors[:new_status], "can't be blank"
  end
end

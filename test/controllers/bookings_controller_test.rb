require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = provider_profiles(:one)

    post login_url, params: {
      email: @customer.email,
      password: "password123"
    }
  end

  test "should require login for bookings" do
    delete logout_url

    get bookings_url

    assert_redirected_to login_path
  end

  test "should get bookings index for customer" do
    get bookings_url

    assert_response :success
  end

  test "should get new booking page" do
    get new_booking_url(provider_id: @provider.id)

    assert_response :success
  end

  test "should create booking" do
    address = @customer.addresses.first || @customer.addresses.create!(
      label: "Test Home",
      street: "Test Street",
      city: "Lahore",
      postal_code: "54000",
      latitude: 31.5,
      longitude: 74.3,
      is_default: true
    )

    service = @provider.provider_services.first

    scheduled_at = Time.zone.parse("2026-08-17 11:00:00")

    assert_difference("Booking.count", 1) do
      post bookings_url, params: {
        booking: {
          provider_id: @provider.id,
          service_category_id: service.service_category_id,
          address_id: address.id,
          scheduled_at: scheduled_at,
          estimated_duration: service.duration_minutes,
          customer_description: "Electrical repair needed.",
          estimated_price: service.base_price
        }
      }
    end

    assert_redirected_to booking_path(Booking.last)
  end
end

require "test_helper"

class Api::V1::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider_user = users(:two)
    @provider = provider_profiles(:one)
    @service_category = service_categories(:one)
    @address = addresses(:one)

    @customer_token = login_as(@customer, "password123")
    @provider_token = login_as(@provider_user, "password123")
  end

  test "customer can create a booking" do
    assert_difference("Booking.count", 1) do
      post "/api/v1/bookings",
           params: {
             booking: {
               provider_id: @provider.id,
               service_category_id: @service_category.id,
               address_id: @address.id,
               scheduled_at: "2026-08-17T10:00:00Z",
               estimated_duration: 60,
               customer_description: "API booking test",
               estimated_price: 1500
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           },
           as: :json
    end

    assert_response :created

    response_body = JSON.parse(response.body)

    assert_equal "Booking created successfully", response_body["message"]
    assert_equal "pending", response_body["booking"]["status"]
    assert_equal @customer.id, response_body["booking"]["customer_id"]
    assert_equal @provider.id, response_body["booking"]["provider_id"]
  end

  test "provider cannot create a booking" do
    post "/api/v1/bookings",
         params: {
           booking: {
             provider_id: @provider.id,
             service_category_id: @service_category.id,
             address_id: @address.id,
             scheduled_at: "2026-08-17T10:00:00Z",
             estimated_duration: 60,
             customer_description: "Provider booking test",
             estimated_price: 1500
           }
         },
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         },
         as: :json

    assert_response :forbidden

    response_body = JSON.parse(response.body)

    assert_equal "Only customers can create bookings",
                 response_body["error"]
  end

  test "request without authentication token is rejected" do
    get "/api/v1/bookings"

    assert_response :unauthorized

    response_body = JSON.parse(response.body)

    assert_equal "Authorization token is missing",
                 response_body["error"]
  end

  test "complete booking lifecycle creates status history and notifications" do
    post "/api/v1/bookings",
         params: {
           booking: {
             provider_id: @provider.id,
             service_category_id: @service_category.id,
             address_id: @address.id,
             scheduled_at: "2026-08-17T13:00:00Z",
             estimated_duration: 60,
             customer_description: "Complete lifecycle test",
             estimated_price: 1500
           }
         },
         headers: {
           "Authorization" => "Bearer #{@customer_token}"
         },
         as: :json

    assert_response :created

    booking_id = JSON.parse(response.body)["booking"]["id"]

    # Provider accepts booking
    patch "/api/v1/bookings/#{booking_id}/accept",
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    booking = Booking.find(booking_id)
    assert_equal "accepted", booking.status

    # Customer confirms booking
    patch "/api/v1/bookings/#{booking_id}/confirm",
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :success

    booking.reload
    assert_equal "confirmed", booking.status

    # Provider starts booking
    patch "/api/v1/bookings/#{booking_id}/start",
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    booking.reload
    assert_equal "in_progress", booking.status
    assert_not_nil booking.started_at

    # Provider completes booking
    patch "/api/v1/bookings/#{booking_id}/complete",
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    booking.reload

    assert_equal "completed", booking.status
    assert_not_nil booking.completed_at

    # Verify status history
    histories = booking.status_histories.order(:id)

    assert_equal 4, histories.count

    assert_equal [ 0, 1 ], [
      histories[0].previous_status,
      histories[0].new_status
    ]

    assert_equal [ 1, 3 ], [
      histories[1].previous_status,
      histories[1].new_status
    ]

    assert_equal [ 3, 4 ], [
      histories[2].previous_status,
      histories[2].new_status
    ]

    assert_equal [ 4, 5 ], [
      histories[3].previous_status,
      histories[3].new_status
    ]

    # Verify notifications
    notifications = Notification.where(booking: booking).order(:id)

    assert_equal 4, notifications.count

    assert_equal "booking_accepted",
                 notifications[0].notification_type

    assert_equal "booking_confirmed",
                 notifications[1].notification_type

    assert_equal "booking_in_progress",
                 notifications[2].notification_type

    assert_equal "booking_completed",
                 notifications[3].notification_type
  end

  private

  def login_as(user, password)
    post "/api/v1/auth/login",
         params: {
           email: user.email,
           password: password
         },
         as: :json

    assert_response :success

    response_body = JSON.parse(response.body)

    assert_equal "Login successful", response_body["message"]

    response_body["token"]
  end
end

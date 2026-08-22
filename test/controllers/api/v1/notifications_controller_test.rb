require "test_helper"

class Api::V1::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @notification = notifications(:one)
  end

  test "customer can list their notifications" do
    get "/api/v1/notifications",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    response_data = JSON.parse(response.body)

    assert response_data["notifications"].is_a?(Array)
  end

  test "customer can show their notification" do
    get "/api/v1/notifications/#{@notification.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    response_data = JSON.parse(response.body)

    assert_equal @notification.id, response_data["notification"]["id"]
  end

  test "customer can mark notification as read" do
    patch "/api/v1/notifications/#{@notification.id}/read",
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :success

    @notification.reload

    assert_equal true, @notification.read
  end

  test "customer can mark all notifications as read" do
    customer_notifications = @customer.notifications

    assert customer_notifications.any?

    customer_notifications.update_all(read: false)

    patch "/api/v1/notifications/read_all",
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :success

    customer_notifications.reload

    assert customer_notifications.all?(&:read)
  end

  test "customer cannot access another user's notification" do
    get "/api/v1/notifications/#{notifications(:two).id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found
  end
end

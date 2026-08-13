require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)
  end

  test "customer can view their own profile" do
    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @customer.id, data["user"]["id"]
    assert_equal @customer.first_name, data["user"]["first_name"]
    assert_equal @customer.last_name, data["user"]["last_name"]
    assert_equal @customer.email, data["user"]["email"]
    assert_equal "customer", data["user"]["role"]
  end

  test "provider can view their own profile" do
    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @provider.id, data["user"]["id"]
    assert_equal @provider.first_name, data["user"]["first_name"]
    assert_equal @provider.last_name, data["user"]["last_name"]
    assert_equal @provider.email, data["user"]["email"]
    assert_equal "provider", data["user"]["role"]
  end

  test "request without token is unauthorized" do
    get "/api/v1/users/me"

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Authorization token is missing", data["error"]
  end

  test "request with invalid token is unauthorized" do
    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer invalid_token"
        }

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Invalid or expired token", data["error"]
  end
end

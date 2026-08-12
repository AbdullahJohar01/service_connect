require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @customer_token = JwtService.encode(@customer.id)
  end

  test "authentication test endpoint works without token" do
    post "/api/v1/auth/test"

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal "Authentication API is working", data["message"]
  end

  test "customer can login with valid credentials" do
    post "/api/v1/auth/login",
         params: {
           email: @customer.email,
           password: "password123"
         }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal "Login successful", data["message"]
    assert data["token"].present?
    assert_equal @customer.id, data["user"]["id"]
    assert_equal @customer.email, data["user"]["email"]
    assert_equal "customer", data["user"]["role"]
  end

  test "login fails with invalid password" do
    post "/api/v1/auth/login",
         params: {
           email: @customer.email,
           password: "wrong-password"
         }

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Invalid email or password", data["error"]
  end

  test "login fails with unknown email" do
    post "/api/v1/auth/login",
         params: {
           email: "does-not-exist@example.com",
           password: "password123"
         }

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Invalid email or password", data["error"]
  end

  test "authenticated user can access their profile" do
    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @customer.id, data["user"]["id"]
    assert_equal @customer.email, data["user"]["email"]
    assert_equal "customer", data["user"]["role"]
  end

  test "request without token is rejected" do
    get "/api/v1/users/me"

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Authorization token is missing", data["error"]
  end

  test "request with invalid token is rejected" do
    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer invalid-token"
        }

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "Invalid or expired token", data["error"]
  end
end

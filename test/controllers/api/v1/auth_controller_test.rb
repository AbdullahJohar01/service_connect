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

  test "customer can register successfully" do
    assert_difference("User.count", 1) do
      post "/api/v1/auth/register",
           params: {
             user: {
               first_name: "New",
               last_name: "Customer",
               email: "new_customer@example.com",
               password: "password123",
               password_confirmation: "password123",
               phone_number: "03000000099"
             }
           }
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal "User registered successfully", data["message"]
    assert data["user"]["id"].present?
    assert_equal "New", data["user"]["first_name"]
    assert_equal "Customer", data["user"]["last_name"]
    assert_equal "new_customer@example.com", data["user"]["email"]
    assert_equal "03000000099", data["user"]["phone_number"]
    assert_equal "customer", data["user"]["role"]
  end

  test "registration fails with invalid user data" do
    assert_no_difference("User.count") do
      post "/api/v1/auth/register",
           params: {
             user: {
               first_name: "",
               last_name: "Customer",
               email: "invalid-email",
               password: "password123",
               password_confirmation: "password123",
               phone_number: ""
             }
           }
    end

    assert_response :unprocessable_content

    data = JSON.parse(response.body)

    assert data["errors"].present?
  end

  test "registration fails when email already exists" do
    assert_no_difference("User.count") do
      post "/api/v1/auth/register",
           params: {
             user: {
               first_name: "Another",
               last_name: "Customer",
               email: @customer.email,
               password: "password123",
               password_confirmation: "password123",
               phone_number: "03000000098"
             }
           }
    end

    assert_response :unprocessable_content

    data = JSON.parse(response.body)

    assert data["errors"].any? { |error| error.include?("Email") }
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

  test "request with token for missing user is rejected" do
    token = JwtService.encode(999999)

    get "/api/v1/users/me",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

    assert_response :unauthorized

    data = JSON.parse(response.body)

    assert_equal "User not found", data["error"]
  end
end

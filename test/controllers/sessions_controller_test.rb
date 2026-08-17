require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should show login page" do
    get login_url

    assert_response :success
  end

  test "should login with valid credentials" do
    user = users(:one)

    post login_url, params: {
      email: user.email,
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should reject invalid credentials" do
    post login_url, params: {
      email: "wrong@example.com",
      password: "wrongpassword"
    }

    assert_response :unprocessable_content
  end

  test "should logout" do
    user = users(:one)

    post login_url, params: {
      email: user.email,
      password: "password123"
    }

    delete logout_url

    assert_redirected_to root_path
  end
end

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get dashboard_path

    assert_redirected_to login_path
  end

  test "should show dashboard for authenticated customer" do
    post login_path, params: {
      email: "customer_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path

    get dashboard_path

    assert_response :success
    assert_select "h1", /Welcome back/
  end
end

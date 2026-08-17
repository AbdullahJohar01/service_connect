require "test_helper"

class ProviderDashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get provider_dashboard_path

    assert_redirected_to login_path
  end

  test "should show dashboard for authenticated provider" do
    post login_path, params: {
      email: "provider_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path

    get provider_dashboard_path

    assert_response :success
    assert_select "h1", /Welcome back/
  end

  test "should reject authenticated customer" do
    post login_path, params: {
      email: "customer_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path

    get provider_dashboard_path

    assert_redirected_to root_path
  end
end

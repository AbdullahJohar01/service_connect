require "test_helper"

class ProviderServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: {
      email: "provider_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should get index" do
    get provider_services_path

    assert_response :success
    assert_select "h1", /My Services/
  end

  test "should get new" do
    get new_provider_service_path

    assert_response :success
    assert_select "h1", /Add Service/
  end

  test "should get edit" do
    provider_profile = User.find_by(
      email: "provider_test@example.com"
    ).provider_profile

    service = provider_profile.provider_services.first

    get edit_provider_service_path(service)

    assert_response :success
    assert_select "h1", /Edit Service/
  end
end

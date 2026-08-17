require "test_helper"

class AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: {
      email: "provider_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should get index" do
    get provider_availabilities_path

    assert_response :success
    assert_select "h1", /My Availability/
  end

  test "should get new" do
    get new_provider_availability_path

    assert_response :success
    assert_select "h1", /Add Availability/
  end

  test "should get edit" do
    provider_profile = User.find_by(
      email: "provider_test@example.com"
    ).provider_profile

    availability = provider_profile.availabilities.first

    get edit_provider_availability_path(availability)

    assert_response :success
    assert_select "h1", /Edit Availability/
  end
end

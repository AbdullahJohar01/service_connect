require "test_helper"

class ProviderProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: {
      email: "provider_test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should get show" do
    get provider_profile_path

    assert_response :success
    assert_select "h1", /Test Electrical Services/
  end

  test "should get edit" do
    get edit_provider_profile_path

    assert_response :success
    assert_select "h1", /Edit Profile/
  end
end

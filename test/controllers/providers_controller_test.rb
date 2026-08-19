require "test_helper"

class ProvidersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get providers_url

    assert_response :success
  end

  test "should show approved provider" do
    provider = provider_profiles(:one)

    get provider_url(provider)

    assert_response :success
  end

  test "should redirect when provider does not exist" do
    get provider_url(999999)

    assert_redirected_to providers_path
  end

  test "should not show unapproved provider" do
    provider = provider_profiles(:two)

    provider.update!(approval_status: :pending)

    get provider_url(provider)

    assert_redirected_to providers_path
  end
end

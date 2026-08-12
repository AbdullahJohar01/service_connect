require "test_helper"

class Api::V1::ProviderProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @provider_profile = @provider.provider_profile
  end

  test "provider can show their profile" do
    get "/api/v1/provider-profile",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @provider_profile.id, data["provider_profile"]["id"]
    assert_equal @provider.id, data["provider_profile"]["user_id"]
  end

  test "provider can update their profile" do
    patch "/api/v1/provider-profile",
          params: {
            provider_profile: {
              business_name: "Updated Provider Services",
              description: "Updated service description",
              experience_years: 7,
              hourly_rate: 2000
            }
          },
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    @provider_profile.reload

    assert_equal "Updated Provider Services",
                 @provider_profile.business_name

    assert_equal "Updated service description",
                 @provider_profile.description

    assert_equal 7,
                 @provider_profile.experience_years

    assert_equal 2000.0,
                 @provider_profile.hourly_rate.to_f
  end

  test "customer cannot access provider profile" do
    get "/api/v1/provider-profile",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found
  end

  test "customer cannot update provider profile" do
    patch "/api/v1/provider-profile",
          params: {
            provider_profile: {
              business_name: "Not Allowed"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :not_found

    @provider_profile.reload

    assert_not_equal "Not Allowed",
                     @provider_profile.business_name
  end
end

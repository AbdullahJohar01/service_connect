require "test_helper"

class Api::V1::CustomerProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @customer_profile = @customer.customer_profile
  end

  test "customer can show their profile" do
    get "/api/v1/customer-profile",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @customer_profile.id, data["customer_profile"]["id"]
    assert_equal @customer.id, data["customer_profile"]["user_id"]
  end

  test "customer can update their profile" do
    patch "/api/v1/customer-profile",
          params: {
            customer_profile: {
              preferred_language: "Urdu"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :success

    @customer_profile.reload

    assert_equal "Urdu", @customer_profile.preferred_language
  end

  test "customer cannot create a second customer profile" do
    post "/api/v1/customer-profile",
         params: {
           customer_profile: {
             date_of_birth: "1998-05-10",
             preferred_language: "English"
           }
         },
         headers: {
           "Authorization" => "Bearer #{@customer_token}"
         }

    assert_response :unprocessable_entity

    data = JSON.parse(response.body)

    assert_equal "Customer profile already exists", data["error"]
  end

  test "provider cannot access customer profile" do
    get "/api/v1/customer-profile",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :forbidden
  end
end

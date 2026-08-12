require "test_helper"

class Api::V1::ProviderServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider_user = users(:two)
    @customer = users(:one)
    @provider = provider_profiles(:one)
    @category = service_categories(:one)

    @provider_token = JwtService.encode(@provider_user.id)
    @customer_token = JwtService.encode(@customer.id)

    @provider_service = ProviderService.create!(
      provider_profile: @provider,
      service_category: @category,
      description: "Electrical installation",
      base_price: 1500,
      duration_minutes: 60,
      active: true
    )
  end

  test "provider can list their services" do
    get "/api/v1/provider-services",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["provider_services"].is_a?(Array)

    assert data["provider_services"].any? do |service|
      service["id"] == @provider_service.id &&
        service["provider_profile_id"] == @provider.id
    end
  end

  test "customer can list active provider services" do
    get "/api/v1/provider-services",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["provider_services"].is_a?(Array)

    assert data["provider_services"].any? do |service|
      service["id"] == @provider_service.id
    end
  end

  test "provider can create a service" do
    assert_difference("ProviderService.count", 1) do
      post "/api/v1/provider-services",
           params: {
             provider_service: {
               service_category_id: @category.id,
               description: "Home wiring",
               base_price: 2000,
               duration_minutes: 90,
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal "Provider service created successfully", data["message"]
    assert_equal 2000.0, data["provider_service"]["base_price"].to_f
  end

  test "customer cannot create a provider service" do
    assert_no_difference("ProviderService.count") do
      post "/api/v1/provider-services",
           params: {
             provider_service: {
               service_category_id: @category.id,
               description: "Not allowed",
               base_price: 1000,
               duration_minutes: 60,
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :forbidden
  end

  test "provider can update their service" do
    patch "/api/v1/provider-services/#{@provider_service.id}",
          params: {
            provider_service: {
              description: "Updated electrical service",
              base_price: 1800
            }
          },
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    @provider_service.reload

    assert_equal "Updated electrical service",
                 @provider_service.description

    assert_equal 1800.0,
                 @provider_service.base_price.to_f
  end

  test "provider can delete their service" do
    assert_difference("ProviderService.count", -1) do
      delete "/api/v1/provider-services/#{@provider_service.id}",
             headers: {
               "Authorization" => "Bearer #{@provider_token}"
             }
    end

    assert_response :success
  end

  test "customer can access an active provider service" do
    get "/api/v1/provider-services/#{@provider_service.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @provider_service.id,
                 data["provider_service"]["id"]
  end
end

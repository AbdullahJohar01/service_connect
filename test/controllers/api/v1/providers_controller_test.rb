require "test_helper"
class Api::V1::ProvidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @provider_profile = provider_profiles(:one)
    @availability = availabilities(:one)
  end

  test "customer can list approved providers" do
    get "/api/v1/providers",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["providers"].any?

    provider = data["providers"].find do |item|
      item["id"] == @provider_profile.id
    end

    assert_not_nil provider
    assert_equal @provider_profile.user_id, provider["user_id"]
    assert_equal @provider_profile.business_name, provider["business_name"]
  end

  test "provider can list approved providers" do
    get "/api/v1/providers",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["providers"].any?
  end

  test "show returns an approved provider" do
    get "/api/v1/providers/#{@provider_profile.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @provider_profile.id, data["provider"]["id"]
    assert_equal @provider_profile.user_id, data["provider"]["user_id"]
    assert_equal @provider_profile.business_name,
                 data["provider"]["business_name"]
    assert_equal @provider_profile.description,
                 data["provider"]["description"]
  end

  test "show returns not found for missing provider" do
    get "/api/v1/providers/999999",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found", data["error"]
  end

  test "show returns not found for unapproved provider" do
    @provider_profile.update!(approval_status: :pending)

    get "/api/v1/providers/#{@provider_profile.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found", data["error"]
  end

  test "customer can view provider availability" do
    get "/api/v1/providers/#{@provider_profile.id}/availability",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["availability"].any?

    availability = data["availability"].find do |item|
      item["id"] == @availability.id
    end

    assert_not_nil availability
    assert_equal @availability.day_of_week,
                 availability["day_of_week"]
    assert_equal true, availability["active"]
  end

  test "provider can view provider availability" do
    get "/api/v1/providers/#{@provider_profile.id}/availability",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["availability"].any?
  end

  test "availability returns not found for missing provider" do
    get "/api/v1/providers/999999/availability",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found", data["error"]
  end

  test "availability returns only active availabilities" do
    inactive = @provider_profile.availabilities.create!(
      day_of_week: 4,
      start_time: "10:00",
      end_time: "12:00",
      active: false
    )

    get "/api/v1/providers/#{@provider_profile.id}/availability",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    ids = data["availability"].map { |item| item["id"] }

    assert_not_includes ids, inactive.id
  end
end

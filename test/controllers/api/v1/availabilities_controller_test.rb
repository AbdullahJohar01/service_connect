require "test_helper"

class Api::V1::AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)
    @other_provider = users(:three)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)
    @other_provider_token = JwtService.encode(@other_provider.id)

    @provider_profile = provider_profiles(:one)
    @other_provider_profile = provider_profiles(:two)

    @availability = availabilities(:one)
    @other_availability = availabilities(:two)
  end

  test "provider can list their availabilities" do
    get "/api/v1/availabilities",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["availabilities"].any?
    assert data["availabilities"].all? do |availability|
      availability["provider_profile_id"] == @provider_profile.id
    end
  end

  test "customer can list active availabilities" do
    get "/api/v1/availabilities",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["availabilities"].any?
    assert data["availabilities"].all? do |availability|
      availability["active"] == true
    end
  end

  test "provider can show their own availability" do
    get "/api/v1/availabilities/#{@availability.id}",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @availability.id, data["availability"]["id"]
    assert_equal @provider_profile.id,
                 data["availability"]["provider_profile_id"]
  end

  test "provider cannot show another provider's availability" do
    get "/api/v1/availabilities/#{@other_availability.id}",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "You cannot access this availability", data["error"]
  end

  test "customer can show active availability" do
    get "/api/v1/availabilities/#{@availability.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @availability.id, data["availability"]["id"]
  end

  test "provider can create availability" do
    assert_difference("Availability.count", 1) do
      post "/api/v1/availabilities",
           params: {
             availability: {
               day_of_week: 3,
               start_time: "10:00",
               end_time: "14:00",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal "Availability created successfully", data["message"]
    assert_equal 3, data["availability"]["day_of_week"]
    assert_equal true, data["availability"]["active"]
    assert_equal @provider_profile.id,
                 data["availability"]["provider_profile_id"]
  end

  test "customer cannot create availability" do
    assert_no_difference("Availability.count") do
      post "/api/v1/availabilities",
           params: {
             availability: {
               day_of_week: 3,
               start_time: "10:00",
               end_time: "14:00",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "Only providers can create availability", data["error"]
  end

  test "provider cannot create overlapping availability" do
    assert_no_difference("Availability.count") do
      post "/api/v1/availabilities",
           params: {
             availability: {
               day_of_week: @availability.day_of_week,
               start_time: "10:00",
               end_time: "12:00",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :unprocessable_entity

    data = JSON.parse(response.body)

    assert_equal "Availability could not be created", data["error"]
  end

  test "provider can update their own availability" do
    patch "/api/v1/availabilities/#{@availability.id}",
          params: {
            availability: {
              start_time: "10:00",
              end_time: "18:00"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal "Availability updated successfully", data["message"]
  end

  test "provider cannot update another provider's availability" do
    patch "/api/v1/availabilities/#{@other_availability.id}",
          params: {
            availability: {
              start_time: "10:00",
              end_time: "18:00"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@provider_token}"
          }

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "Provider access required", data["error"]
  end

  test "customer cannot update availability" do
    patch "/api/v1/availabilities/#{@availability.id}",
          params: {
            availability: {
              start_time: "10:00",
              end_time: "18:00"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "Provider access required", data["error"]
  end

  test "provider can delete their own availability" do
    assert_difference("Availability.count", -1) do
      delete "/api/v1/availabilities/#{@availability.id}",
             headers: {
               "Authorization" => "Bearer #{@provider_token}"
             }
    end

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal "Availability deleted successfully", data["message"]
  end

  test "provider cannot delete another provider's availability" do
    assert_no_difference("Availability.count") do
      delete "/api/v1/availabilities/#{@other_availability.id}",
             headers: {
               "Authorization" => "Bearer #{@provider_token}"
             }
    end

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "Provider access required", data["error"]
  end

  test "customer cannot delete availability" do
    assert_no_difference("Availability.count") do
      delete "/api/v1/availabilities/#{@availability.id}",
             headers: {
               "Authorization" => "Bearer #{@customer_token}"
             }
    end

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal "Provider access required", data["error"]
  end

  test "invalid availability returns unprocessable entity" do
    assert_no_difference("Availability.count") do
      post "/api/v1/availabilities",
           params: {
             availability: {
               day_of_week: 4,
               start_time: "17:00",
               end_time: "09:00",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :unprocessable_entity

    data = JSON.parse(response.body)

    assert_equal "Availability could not be created", data["error"]
  end

  test "requesting missing availability returns not found" do
    get "/api/v1/availabilities/999999",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Availability not found", data["error"]
  end
end

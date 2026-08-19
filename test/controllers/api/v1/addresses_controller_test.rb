require "test_helper"

class Api::V1::AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)

    @token = JwtService.encode(@user.id)
    @other_token = JwtService.encode(@other_user.id)

    @address = addresses(:one)
  end

  test "customer can list their addresses" do
    get "/api/v1/addresses",
        headers: {
          "Authorization" => "Bearer #{@token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["addresses"].is_a?(Array)
    assert data["addresses"].any? do |address|
      address["id"] == @address.id &&
        address["user_id"] == @user.id
    end
  end

  test "customer can show their address" do
    get "/api/v1/addresses/#{@address.id}",
        headers: {
          "Authorization" => "Bearer #{@token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @address.id, data["address"]["id"]
    assert_equal @user.id, data["address"]["user_id"]
  end

  test "customer can create an address" do
    assert_difference("Address.count", 1) do
      post "/api/v1/addresses",
           params: {
             address: {
               label: "New Home",
               street: "789 New Street",
               city: "Karachi",
               postal_code: "75600",
               latitude: 24.8700,
               longitude: 67.0100,
               is_default: false
             }
           },
           headers: {
             "Authorization" => "Bearer #{@token}"
           }
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal "Address created successfully", data["message"]
    assert_equal @user.id, data["address"]["user_id"]
    assert_equal "New Home", data["address"]["label"]
  end

  test "customer can update their address" do
    patch "/api/v1/addresses/#{@address.id}",
          params: {
            address: {
              label: "Updated Home",
              city: "Lahore"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@token}"
          }

    assert_response :success

    @address.reload

    assert_equal "Updated Home", @address.label
    assert_equal "Lahore", @address.city
  end

  test "customer can delete their address" do
    assert_difference("Address.count", -1) do
      delete "/api/v1/addresses/#{@address.id}",
             headers: {
               "Authorization" => "Bearer #{@token}"
             }
    end

    assert_response :success
  end

  test "customer cannot access another user's address" do
    other_address = addresses(:two)

    get "/api/v1/addresses/#{other_address.id}",
        headers: {
          "Authorization" => "Bearer #{@token}"
        }

    assert_response :not_found
  end

  test "customer cannot update another user's address" do
    other_address = addresses(:two)

    patch "/api/v1/addresses/#{other_address.id}",
          params: {
            address: {
              label: "Not allowed"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@token}"
          }

    assert_response :not_found
  end

  test "customer cannot delete another user's address" do
    other_address = addresses(:two)

    assert_no_difference("Address.count") do
      delete "/api/v1/addresses/#{other_address.id}",
             headers: {
               "Authorization" => "Bearer #{@token}"
             }
    end

    assert_response :not_found
  end
end

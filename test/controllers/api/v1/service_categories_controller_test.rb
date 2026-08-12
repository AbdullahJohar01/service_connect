require "test_helper"

class Api::V1::ServiceCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @category = service_categories(:one)
  end

  test "authenticated user can list active service categories" do
    get "/api/v1/service-categories",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data["service_categories"].is_a?(Array)

    assert data["service_categories"].any? do |category|
      category["id"] == @category.id &&
        category["name"] == "Electrical"
    end
  end

  test "inactive categories are not included in index" do
    inactive_category = ServiceCategory.create!(
      name: "Inactive Category",
      description: "Not available",
      active: false
    )

    get "/api/v1/service-categories",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    ids = data["service_categories"].map { |category| category["id"] }

    assert_not_includes ids, inactive_category.id
  end

  test "authenticated user can show a service category" do
    get "/api/v1/service-categories/#{@category.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal @category.id,
                 data["service_category"]["id"]

    assert_equal "Electrical",
                 data["service_category"]["name"]
  end

  test "admin can create a service category" do
    admin = User.create!(
      first_name: "Test",
      last_name: "Admin",
      email: "admin_category_test@example.com",
      password: "password123",
      phone_number: "03000000003",
      role: :admin,
      status: :active
    )

    admin_token = JwtService.encode(admin.id)

    assert_difference("ServiceCategory.count", 1) do
      post "/api/v1/service-categories",
           params: {
             service_category: {
               name: "Cleaning",
               description: "Home cleaning services",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{admin_token}"
           }
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal "Service category created successfully",
                 data["message"]

    assert_equal "Cleaning",
                 data["service_category"]["name"]
  end

  test "customer cannot create a service category" do
    assert_no_difference("ServiceCategory.count") do
      post "/api/v1/service-categories",
           params: {
             service_category: {
               name: "Not Allowed",
               description: "Should not be created",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :forbidden
  end

  test "provider cannot create a service category" do
    assert_no_difference("ServiceCategory.count") do
      post "/api/v1/service-categories",
           params: {
             service_category: {
               name: "Not Allowed",
               description: "Should not be created",
               active: true
             }
           },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :forbidden
  end

  test "admin can update a service category" do
    admin = User.create!(
      first_name: "Test",
      last_name: "Admin",
      email: "admin_category_update@example.com",
      password: "password123",
      phone_number: "03000000004",
      role: :admin,
      status: :active
    )

    admin_token = JwtService.encode(admin.id)

    patch "/api/v1/service-categories/#{@category.id}",
          params: {
            service_category: {
              name: "Updated Electrical",
              description: "Updated electrical services"
            }
          },
          headers: {
            "Authorization" => "Bearer #{admin_token}"
          }

    assert_response :success

    @category.reload

    assert_equal "Updated Electrical", @category.name
    assert_equal "Updated electrical services", @category.description
  end

  test "customer cannot update a service category" do
    patch "/api/v1/service-categories/#{@category.id}",
          params: {
            service_category: {
              name: "Not Allowed"
            }
          },
          headers: {
            "Authorization" => "Bearer #{@customer_token}"
          }

    assert_response :forbidden

    @category.reload

    assert_equal "Electrical", @category.name
  end

  test "admin can deactivate a service category" do
    admin = User.create!(
      first_name: "Test",
      last_name: "Admin",
      email: "admin_category_delete@example.com",
      password: "password123",
      phone_number: "03000000005",
      role: :admin,
      status: :active
    )

    admin_token = JwtService.encode(admin.id)

    delete "/api/v1/service-categories/#{@category.id}",
           headers: {
             "Authorization" => "Bearer #{admin_token}"
           }

    assert_response :success

    @category.reload

    assert_equal false, @category.active
  end

  test "customer cannot deactivate a service category" do
    delete "/api/v1/service-categories/#{@category.id}",
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }

    assert_response :forbidden

    @category.reload

    assert_equal true, @category.active
  end

  test "show returns not found for missing category" do
    get "/api/v1/service-categories/999999",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Service category not found", data["error"]
  end
end

require "test_helper"

class Api::V1::ProvidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @provider_profile = provider_profiles(:one)
    @other_provider_profile = provider_profiles(:two)

    @availability = availabilities(:one)

    @electrical_category = service_categories(:one)
    @plumbing_category = service_categories(:two)

    @provider_service = @provider_profile.provider_services.create!(
      service_category: @electrical_category,
      description: "Electrical services",
      base_price: 1500,
      duration_minutes: 60,
      active: true
    )

    @other_provider_service = @other_provider_profile.provider_services.create!(
      service_category: @plumbing_category,
      description: "Plumbing services",
      base_price: 2500,
      duration_minutes: 60,
      active: true
    )
  end

  # ---------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------

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

    assert_equal @provider_profile.user_id,
                 provider["user_id"]

    assert_equal @provider_profile.business_name,
                 provider["business_name"]

    assert_equal @provider_profile.description,
                 provider["description"]

    assert_equal @provider_profile.experience_years,
                 provider["experience_years"]

    assert_equal @provider_profile.hourly_rate.to_s,
                 provider["hourly_rate"]

    assert_equal @provider_profile.average_rating.to_s,
                 provider["average_rating"]

    assert_equal @provider_profile.total_reviews,
                 provider["total_reviews"]
  end

  test "only approved providers appear in provider search" do
    @provider_profile.update!(approval_status: :pending)

    get "/api/v1/providers",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_not_includes provider_ids, @provider_profile.id
  end

  # ---------------------------------------------------------
  # CATEGORY FILTER
  # ---------------------------------------------------------

  test "customer can filter providers by service category" do
    get "/api/v1/providers?service_category_id=#{@electrical_category.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_includes provider_ids, @provider_profile.id
    assert_not_includes provider_ids, @other_provider_profile.id
  end

  test "category_id alias works" do
    get "/api/v1/providers?category_id=#{@electrical_category.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_includes provider_ids, @provider_profile.id
  end

  test "inactive provider services are excluded" do
    @provider_service.update!(active: false)

    get "/api/v1/providers?category_id=#{@electrical_category.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_not_includes provider_ids, @provider_profile.id
  end

  # ---------------------------------------------------------
  # CITY FILTER
  # ---------------------------------------------------------

  test "customer can filter providers by city" do
    get "/api/v1/providers?city=Lahore",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("providers")
    assert data.key?("pagination")
  end

  test "city filter excludes providers from another city" do
    get "/api/v1/providers?city=Islamabad",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_not_includes provider_ids, @provider_profile.id
  end

  # ---------------------------------------------------------
  # RATING FILTER
  # ---------------------------------------------------------

  test "customer can filter providers by minimum rating" do
    get "/api/v1/providers?min_rating=4",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    data["providers"].each do |provider|
      assert_operator provider["average_rating"].to_f, :>=, 4.0
    end
  end

  test "minimum_rating alias works" do
    get "/api/v1/providers?minimum_rating=4",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("providers")
  end

  # ---------------------------------------------------------
  # PRICE FILTERS
  # ---------------------------------------------------------

  test "customer can filter providers by minimum price" do
    get "/api/v1/providers?min_price=2000",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_includes provider_ids, @other_provider_profile.id
    assert_not_includes provider_ids, @provider_profile.id
  end

  test "customer can filter providers by maximum price" do
    get "/api/v1/providers?max_price=2000",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_includes provider_ids, @provider_profile.id
    assert_not_includes provider_ids, @other_provider_profile.id
  end

  test "customer can filter providers by price range" do
    get "/api/v1/providers?min_price=1000&max_price=2000",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_includes provider_ids, @provider_profile.id
    assert_not_includes provider_ids, @other_provider_profile.id
  end

  test "minimum_price and maximum_price aliases work" do
    get "/api/v1/providers?minimum_price=1000&maximum_price=2000",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("providers")
  end

  # ---------------------------------------------------------
  # AVAILABILITY DATE FILTER
  # ---------------------------------------------------------

  test "customer can filter providers by availability date" do
    date = Date.new(2026, 8, 17)

    get "/api/v1/providers?availability_date=#{date.iso8601}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("providers")
    assert data.key?("pagination")
  end

  test "inactive availability is excluded" do
    @availability.update!(active: false)

    date = Date.new(2026, 8, 17)

    get "/api/v1/providers?availability_date=#{date.iso8601}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider_ids = data["providers"].map do |provider|
      provider["id"]
    end

    assert_not_includes provider_ids, @provider_profile.id
  end

  # ---------------------------------------------------------
  # COMBINED FILTERS
  # ---------------------------------------------------------

  test "provider search supports combined filters" do
    date = Date.new(2026, 8, 17)

    get "/api/v1/providers" \
        "?category_id=#{@electrical_category.id}" \
        "&min_price=1000" \
        "&max_price=2000" \
        "&min_rating=0" \
        "&city=Lahore" \
        "&availability_date=#{date.iso8601}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("providers")
    assert data.key?("pagination")
  end

  # ---------------------------------------------------------
  # PAGINATION
  # ---------------------------------------------------------

  test "provider list includes pagination information" do
    get "/api/v1/providers?page=1&per_page=20",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("pagination")

    assert_equal 1,
                 data["pagination"]["page"]

    assert_equal 20,
                 data["pagination"]["per_page"]

    assert data["pagination"].key?("total_count")
    assert data["pagination"].key?("total_pages")
  end

  test "provider list respects per_page" do
    get "/api/v1/providers?page=1&per_page=1",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal 1,
                 data["pagination"]["page"]

    assert_equal 1,
                 data["pagination"]["per_page"]

    assert data["providers"].length <= 1
  end

  test "provider list limits maximum per_page" do
    get "/api/v1/providers?page=1&per_page=500",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal 100,
                 data["pagination"]["per_page"]
  end

  test "invalid page returns bad request" do
    get "/api/v1/providers?page=0",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :bad_request

    data = JSON.parse(response.body)

    assert_equal "Invalid provider search parameters",
                 data["error"]
  end

  # ---------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------

  test "customer can view an approved provider" do
    get "/api/v1/providers/#{@provider_profile.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    provider = data["provider"]

    assert_equal @provider_profile.id,
                 provider["id"]

    assert_equal @provider_profile.user_id,
                 provider["user_id"]

    assert_equal @provider_profile.business_name,
                 provider["business_name"]

    assert_equal @provider_profile.description,
                 provider["description"]

    assert_equal @provider_profile.experience_years,
                 provider["experience_years"]

    assert_equal @provider_profile.hourly_rate.to_s,
                 provider["hourly_rate"]
  end

  test "show returns not found for missing provider" do
    get "/api/v1/providers/999999",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found",
                 data["error"]
  end

  test "show does not return unapproved provider" do
    @provider_profile.update!(
      approval_status: :pending
    )

    get "/api/v1/providers/#{@provider_profile.id}",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found",
                 data["error"]
  end

  # ---------------------------------------------------------
  # AVAILABILITY ENDPOINT
  # ---------------------------------------------------------

  test "customer can view provider availability" do
    get "/api/v1/providers/#{@provider_profile.id}/availability",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("availability")
    assert data["availability"].any?

    availability = data["availability"].find do |item|
      item["id"] == @availability.id
    end

    assert_not_nil availability

    assert_equal @availability.day_of_week,
                 availability["day_of_week"]

    assert_equal true,
                 availability["active"]
  end

  test "availability returns not found for missing provider" do
    get "/api/v1/providers/999999/availability",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found",
                 data["error"]
  end

  test "availability only returns active records" do
    inactive = @provider_profile.availabilities.create!(
      day_of_week: 6,
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

    ids = data["availability"].map do |item|
      item["id"]
    end

    assert_not_includes ids, inactive.id
  end

  # ---------------------------------------------------------
  # REVIEWS
  # ---------------------------------------------------------

  test "customer can view provider reviews" do
    review_booking = create_completed_booking

    review = Review.create!(
      booking: review_booking,
      customer: @customer,
      provider: @provider_profile,
      rating: 5,
      comment: "Excellent service"
    )

    get "/api/v1/providers/#{@provider_profile.id}/reviews",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert data.key?("reviews")
    assert data.key?("pagination")

    returned_review = data["reviews"].find do |item|
      item["id"] == review.id
    end

    assert_not_nil returned_review

    assert_equal 5,
                 returned_review["rating"]

    assert_equal "Excellent service",
                 returned_review["comment"]

    assert_equal @customer.id,
                 returned_review["customer"]["id"]

    assert_equal @customer.first_name,
                 returned_review["customer"]["first_name"]

    assert_equal @customer.last_name,
                 returned_review["customer"]["last_name"]

    assert returned_review.key?("created_at")
    assert returned_review.key?("updated_at")
  end

  test "provider can view their reviews" do
    review_booking = create_completed_booking

    review = Review.create!(
      booking: review_booking,
      customer: @customer,
      provider: @provider_profile,
      rating: 5,
      comment: "Great service"
    )

    get "/api/v1/providers/#{@provider_profile.id}/reviews",
        headers: {
          "Authorization" => "Bearer #{@provider_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    review_ids = data["reviews"].map do |item|
      item["id"]
    end

    assert_includes review_ids, review.id
  end

  test "provider reviews are paginated" do
    review_booking = create_completed_booking

    review = Review.create!(
      booking: review_booking,
      customer: @customer,
      provider: @provider_profile,
      rating: 5,
      comment: "First review"
    )

    get "/api/v1/providers/#{@provider_profile.id}/reviews?page=1&per_page=1",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal 1,
                 data["pagination"]["page"]

    assert_equal 1,
                 data["pagination"]["per_page"]

    assert_equal 1,
                 data["reviews"].length

    assert data["pagination"]["total_count"] >= 1
    assert data["pagination"]["total_pages"] >= 1

    assert_equal review.id,
                 data["reviews"].first["id"]
  end

  test "reviews returns not found for missing provider" do
    get "/api/v1/providers/999999/reviews",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found",
                 data["error"]
  end

  test "reviews are not available for unapproved provider" do
    @provider_profile.update!(
      approval_status: :pending
    )

    get "/api/v1/providers/#{@provider_profile.id}/reviews",
        headers: {
          "Authorization" => "Bearer #{@customer_token}"
        }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal "Provider not found",
                 data["error"]
  end

  # ---------------------------------------------------------
  # PRIVATE TEST HELPERS
  # ---------------------------------------------------------

  private

  def create_completed_booking
    Booking.create!(
      customer: @customer,
      provider: @provider_profile,
      service_category: @electrical_category,
      address: addresses(:one),
      scheduled_at: Time.zone.parse("2026-08-17 10:00:00"),
      estimated_duration: 1,
      customer_description: "Test booking",
      estimated_price: 1500,
      status: :completed,
      completed_at: Time.zone.parse("2026-08-17 11:00:00")
    )
  end
end

require "test_helper"

class Api::V1::ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = provider_profiles(:one)
    @provider.reviews.destroy_all
    @service_category = service_categories(:one)
    @address = addresses(:one)

    @customer_token = JwtService.encode(@customer.id)

    @booking = Booking.create!(
      customer: @customer,
      provider: @provider,
      service_category: @service_category,
      address: @address,
      scheduled_at: Time.zone.parse("2026-08-17 10:00:00"),
      estimated_duration: 60,
      customer_description: "Controller review test",
      estimated_price: 1500,
      status: :completed,
      completed_at: Time.current
    )
  end

  test "customer can create a review for completed booking" do
    assert_difference("Review.count", 1) do
      post "/api/v1/bookings/#{@booking.id}/review",
           params: {
             review: {
               rating: 5,
               comment: "Excellent service"
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :created

    response_data = JSON.parse(response.body)

    assert_equal "Review created successfully", response_data["message"]
    assert_equal 5, response_data["review"]["rating"]
    assert_equal "Excellent service", response_data["review"]["comment"]
  end

  test "customer cannot review an incomplete booking" do
    @booking.update!(
      status: :pending,
      completed_at: nil
    )

    assert_no_difference("Review.count") do
      post "/api/v1/bookings/#{@booking.id}/review",
           params: {
             review: {
               rating: 5,
               comment: "Trying too early"
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :unprocessable_entity
  end

  test "customer cannot review the same booking twice" do
    Review.create!(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: "First review"
    )

    assert_no_difference("Review.count") do
      post "/api/v1/bookings/#{@booking.id}/review",
           params: {
             review: {
               rating: 4,
               comment: "Second review"
             }
           },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :unprocessable_entity
  end

  test "provider rating is updated after review" do
    post "/api/v1/bookings/#{@booking.id}/review",
         params: {
           review: {
             rating: 4,
             comment: "Good service"
           }
         },
         headers: {
           "Authorization" => "Bearer #{@customer_token}"
         }

    assert_response :created

    @provider.reload

    assert_equal 4.0, @provider.average_rating.to_f
    assert_equal 1, @provider.total_reviews
  end

  test "customer can update their own review" do
    review = Review.create!(customer: @customer, provider: @provider, booking: @booking, rating: 4, comment: "Good service")

    patch "/api/v1/reviews/#{review.id}", params: { review: { rating: 5, comment: "Excellent service" } }, headers: { "Authorization" => "Bearer #{@customer_token}" }

    assert_response :success
    assert_equal 5, review.reload.rating
    assert_equal "Excellent service", review.comment
  end
end

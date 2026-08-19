require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @customer = users(:one)
    @provider = provider_profiles(:one)
    @service_category = service_categories(:one)
    @address = addresses(:one)

    @booking = Booking.create!(
      customer: @customer,
      provider: @provider,
      service_category: @service_category,
      address: @address,
      scheduled_at: Time.zone.parse("2026-08-17 10:00:00"),
      estimated_duration: 60,
      customer_description: "Review test booking",
      estimated_price: 1500,
      status: :completed,
      completed_at: Time.current
    )
  end

  test "review is valid for completed booking" do
    review = Review.new(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: "Excellent service"
    )

    assert review.valid?
  end

  test "review requires rating between 1 and 5" do
    review = Review.new(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 6,
      comment: "Excellent service"
    )

    assert_not review.valid?
    assert_includes review.errors.full_messages,
                    "Rating is not included in the list"
  end

  test "review requires a comment" do
    review = Review.new(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: nil
    )

    assert_not review.valid?
    assert_includes review.errors.full_messages,
                    "Comment can't be blank"
  end

  test "review is invalid when booking is not completed" do
    @booking.update!(
      status: :pending,
      completed_at: nil
    )

    review = Review.new(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: "Good service"
    )

    assert_not review.valid?
    assert_includes review.errors.full_messages,
                    "Booking must be completed before reviewing"
  end

  test "review customer must match booking customer" do
    other_customer = User.create!(
      first_name: "Other",
      last_name: "Customer",
      email: "other_review_customer@example.com",
      password: "password123",
      phone_number: "03000000003",
      role: :customer,
      status: :active
    )

    review = Review.new(
      customer: other_customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: "Good service"
    )

    assert_not review.valid?
    assert_includes review.errors.full_messages,
                    "Customer must be the customer of the booking"
  end

  test "review provider must match booking provider" do
    other_provider_user = User.create!(
      first_name: "Other",
      last_name: "Provider",
      email: "other_review_provider@example.com",
      password: "password123",
      phone_number: "03000000004",
      role: :provider,
      status: :active
    )

    other_provider = ProviderProfile.create!(
      user: other_provider_user,
      business_name: "Other Electrical Services",
      description: "Other services",
      experience_years: 3,
      hourly_rate: 1000,
      approval_status: :approved,
      average_rating: 0,
      total_reviews: 0
    )

    review = Review.new(
      customer: @customer,
      provider: other_provider,
      booking: @booking,
      rating: 5,
      comment: "Good service"
    )

    assert_not review.valid?
    assert_includes review.errors.full_messages,
                    "Provider must be the provider of the booking"
  end

  test "only one review can exist for a booking" do
    Review.create!(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 5,
      comment: "Excellent service"
    )

    duplicate = Review.new(
      customer: @customer,
      provider: @provider,
      booking: @booking,
      rating: 4,
      comment: "Another review"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors.full_messages,
                    "Booking has already been taken"
  end
end

class Api::V1::ReviewsController < Api::V1::BaseController
  before_action :set_booking, only: [ :create ]
  before_action :set_review, only: [ :show, :update, :destroy ]

  def index
    render json: { reviews: Review.all.map { |review| review_json(review) } }
  end

  def show
    render json: { review: review_json(@review) }
  end

  def create
    return render(json: { error: "Only customers can create reviews" }, status: :forbidden) unless current_user.customer?
    return render(json: { error: "You cannot review this booking" }, status: :forbidden) unless @booking.customer == current_user
    return render(json: { error: "Booking must be completed before reviewing" }, status: :unprocessable_entity) unless @booking.completed?
    return render(json: { error: "This booking has already been reviewed" }, status: :unprocessable_entity) if @booking.review.present?

    review = @booking.build_review(review_params.merge(customer: current_user, provider: @booking.provider))
    if review.save
      update_provider_rating(@booking.provider)
      render json: { message: "Review created successfully", review: review_json(review) }, status: :created
    else
      render json: { error: "Review could not be created", errors: review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    return render(json: { error: "You cannot update this review" }, status: :forbidden) unless @review.customer == current_user

    if @review.update(review_params)
      update_provider_rating(@review.provider)
      render json: { message: "Review updated successfully", review: review_json(@review) }
    else
      render json: { error: "Review could not be updated", errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    return render(json: { error: "You cannot delete this review" }, status: :forbidden) unless @review.customer == current_user || current_user.admin?

    provider = @review.provider
    @review.destroy
    update_provider_rating(provider)
    render json: { message: "Review deleted successfully" }
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:booking_id])
    return if @booking

    render json: { error: "Booking not found" }, status: :not_found
  end

  def set_review
    @review = Review.find_by(id: params[:id])
    return if @review

    render json: { error: "Review not found" }, status: :not_found
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def update_provider_rating(provider)
    provider.update!(average_rating: provider.reviews.average(:rating) || 0, total_reviews: provider.reviews.count)
  end

  def review_json(review)
    {
      id: review.id,
      customer_id: review.customer_id,
      provider_id: review.provider_id,
      booking_id: review.booking_id,
      rating: review.rating,
      comment: review.comment,
      created_at: review.created_at,
      updated_at: review.updated_at
    }
  end
end

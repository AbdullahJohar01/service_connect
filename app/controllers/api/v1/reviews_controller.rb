class Api::V1::ReviewsController < Api::V1::BaseController
before_action :set_booking, only: [ :create ]
before_action :set_review, only: [ :show, :destroy ]

def index
reviews = Review.all

render json: {
  reviews: reviews.map { |review| review_json(review) }
}
end

def show
render json: {
review: review_json(@review)
}
end

def create
unless current_user.customer?
render json: { error: "Only customers can create reviews" }, status: :forbidden
return
end

unless @booking.customer == current_user
  render json: { error: "You cannot review this booking" }, status: :forbidden
  return
end

unless @booking.completed?
  render json: { error: "Booking must be completed before reviewing" }, status: :unprocessable_entity
  return
end

if @booking.review.present?
  render json: { error: "This booking has already been reviewed" }, status: :unprocessable_entity
  return
end

review = Review.new(review_params)
review.customer = current_user
review.provider = @booking.provider
review.booking = @booking

if review.save
  update_provider_rating(@booking.provider)

  render json: {
    message: "Review created successfully",
    review: review_json(review)
  }, status: :created
else
  render json: {
    error: "Review could not be created",
    errors: review.errors.full_messages
  }, status: :unprocessable_entity
end
end

def destroy
unless @review.customer == current_user || current_user.admin?
render json: { error: "You cannot delete this review" }, status: :forbidden
return
end

provider = @review.provider

@review.destroy
update_provider_rating(provider)

render json: {
  message: "Review deleted successfully"
}
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
params.require(:review).permit(
:rating,
:comment
)
end

def update_provider_rating(provider)
provider.update(
average_rating: provider.reviews.average(:rating) || 0,
total_reviews: provider.reviews.count
)
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

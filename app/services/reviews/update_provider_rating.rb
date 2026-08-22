class Reviews::UpdateProviderRating
  def self.call(provider)
    provider.update!(average_rating: provider.reviews.average(:rating) || 0, total_reviews: provider.reviews.count)
  end
end

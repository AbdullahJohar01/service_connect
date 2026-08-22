class ProviderRatingJob < ApplicationJob
  queue_as :default
  def perform(provider_id)
    provider = ProviderProfile.find_by(id: provider_id)
    Reviews::UpdateProviderRating.call(provider) if provider
  end
end

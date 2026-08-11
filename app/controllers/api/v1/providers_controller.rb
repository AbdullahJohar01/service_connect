class Api::V1::ProvidersController < Api::V1::BaseController
  def index
    providers = ProviderProfile.where(approval_status: :approved)

    render json: {
      providers: providers.map do |provider|
        {
          id: provider.id,
          user_id: provider.user_id,
          business_name: provider.business_name,
          description: provider.description,
          experience_years: provider.experience_years,
          hourly_rate: provider.hourly_rate,
          average_rating: provider.average_rating,
          total_reviews: provider.total_reviews
        }
      end
    }
  end

  def show
    provider = ProviderProfile.find_by(id: params[:id])

    if provider.nil? || !provider.approved?
      render json: { error: "Provider not found" }, status: :not_found
      return
    end

    render json: {
      provider: {
        id: provider.id,
        user_id: provider.user_id,
        business_name: provider.business_name,
        description: provider.description,
        experience_years: provider.experience_years,
        hourly_rate: provider.hourly_rate,
        average_rating: provider.average_rating,
        total_reviews: provider.total_reviews
      }
    }
  end

  def availability
    provider = ProviderProfile.find_by(id: params[:id])

    if provider.nil? || !provider.approved?
      render json: { error: "Provider not found" }, status: :not_found
      return
    end

    availabilities = provider.availabilities
                             .where(active: true)
                             .order(:day_of_week, :start_time)

    render json: {
      availability: availabilities.map do |availability|
        {
          id: availability.id,
          day_of_week: availability.day_of_week,
          start_time: availability.start_time,
          end_time: availability.end_time,
          active: availability.active
        }
      end
    }
  end
end

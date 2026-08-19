class Api::V1::ProvidersController < Api::V1::BaseController
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  def index
    providers = ProviderProfile.where(approval_status: :approved)

    if category_filter.present?
      providers = providers
        .joins(:provider_services)
        .where(
          provider_services: {
            service_category_id: category_filter,
            active: true
          }
        )
        .distinct
    end

    if city_filter.present?
      providers = providers
        .joins(user: :addresses)
        .where(addresses: { city: city_filter })
        .distinct
    end

    if minimum_rating_filter.present?
      providers = providers.where(
        "provider_profiles.average_rating >= ?",
        minimum_rating_filter
      )
    end

    if minimum_price_filter.present?
      providers = providers
        .joins(:provider_services)
        .where(
          "provider_services.base_price >= ?",
          minimum_price_filter
        )
        .where(provider_services: { active: true })
        .distinct
    end

    if maximum_price_filter.present?
      providers = providers
        .joins(:provider_services)
        .where(
          "provider_services.base_price <= ?",
          maximum_price_filter
        )
        .where(provider_services: { active: true })
        .distinct
    end

    if availability_date_filter.present?
      providers = providers
        .joins(:availabilities)
        .where(
          availabilities: {
            day_of_week: availability_date_filter.wday,
            active: true
          }
        )
        .distinct
    end

    providers = providers.order(:id)

    page = pagination_page
    per_page = pagination_per_page

    total_count = providers.count
    total_pages = (total_count.to_f / per_page).ceil

    providers = providers
      .offset((page - 1) * per_page)
      .limit(per_page)

    render json: {
      providers: providers.map { |provider| provider_json(provider) },
      pagination: {
        page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      }
    }
  rescue ArgumentError
    render json: {
      error: "Invalid provider search parameters"
    }, status: :bad_request
  end

  def show
    provider = ProviderProfile.find_by(id: params[:id])

    if provider.nil? || !provider.approved?
      render json: {
        error: "Provider not found"
      }, status: :not_found
      return
    end

    render json: {
      provider: provider_json(provider)
    }
  end

  def availability
    provider = ProviderProfile.find_by(id: params[:id])

    if provider.nil? || !provider.approved?
      render json: {
        error: "Provider not found"
      }, status: :not_found
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

  def reviews
    provider = ProviderProfile.find_by(id: params[:id])

    if provider.nil? || !provider.approved?
      render json: {
        error: "Provider not found"
      }, status: :not_found
      return
    end

    reviews = provider.reviews
      .includes(:customer)
      .order(created_at: :desc)

    page = pagination_page
    per_page = pagination_per_page

    total_count = reviews.count
    total_pages = (total_count.to_f / per_page).ceil

    reviews = reviews
      .offset((page - 1) * per_page)
      .limit(per_page)

    render json: {
      reviews: reviews.map do |review|
        {
          id: review.id,
          rating: review.rating,
          comment: review.comment,
          customer: {
            id: review.customer.id,
            first_name: review.customer.first_name,
            last_name: review.customer.last_name
          },
          created_at: review.created_at,
          updated_at: review.updated_at
        }
      end,
      pagination: {
        page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      }
    }
  rescue ArgumentError
    render json: {
      error: "Invalid pagination parameters"
    }, status: :bad_request
  end

  private

  def provider_json(provider)
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

  def category_filter
    params[:service_category_id].presence ||
      params[:category_id].presence
  end

  def city_filter
    params[:city].presence
  end

  def minimum_rating_filter
    value = params[:min_rating].presence ||
            params[:minimum_rating].presence

    return if value.blank?

    Float(value)
  end

  def minimum_price_filter
    value = params[:min_price].presence ||
            params[:minimum_price].presence

    return if value.blank?

    Float(value)
  end

  def maximum_price_filter
    value = params[:max_price].presence ||
            params[:maximum_price].presence

    return if value.blank?

    Float(value)
  end

  def availability_date_filter
    value = params[:availability_date].presence

    return if value.blank?

    Date.iso8601(value)
  end

  def pagination_page
    value = params[:page].presence || 1
    page = Integer(value)

    raise ArgumentError if page < 1

    page
  end

  def pagination_per_page
    value = params[:per_page].presence || DEFAULT_PER_PAGE
    per_page = Integer(value)

    raise ArgumentError if per_page < 1

    [ per_page, MAX_PER_PAGE ].min
  end
end

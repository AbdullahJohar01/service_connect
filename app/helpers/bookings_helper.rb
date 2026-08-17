module BookingsHelper
  def service_category_name(provider_service)
    provider_service.service_category.name
  end
end

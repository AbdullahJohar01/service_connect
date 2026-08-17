class ProviderService < ApplicationRecord
  belongs_to :provider_profile
  belongs_to :service_category

  validates :base_price, numericality: { greater_than: 0 }
  validates :duration_minutes, numericality: { greater_than: 0 }

  def service_category_name
    service_category.name
  end
end

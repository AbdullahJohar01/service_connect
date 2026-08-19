class ServiceCategory < ApplicationRecord
  has_many :provider_services, dependent: :destroy
  has_many :bookings, dependent: :destroy
end

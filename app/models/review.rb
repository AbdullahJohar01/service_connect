class Review < ApplicationRecord
belongs_to :customer, class_name: "User"
belongs_to :provider, class_name: "ProviderProfile"
belongs_to :booking

validates :rating, inclusion: { in: 1..5 }
validates :comment, presence: true
validates :booking_id, uniqueness: true
after_commit :refresh_provider_rating, on: [ :create, :update, :destroy ]

validate :booking_must_be_completed
validate :customer_must_match_booking
validate :provider_must_match_booking

private

def booking_must_be_completed
return unless booking

unless booking.completed?
  errors.add(:booking, "must be completed before reviewing")
end
end

def customer_must_match_booking
return unless booking && customer

unless booking.customer_id == customer_id
  errors.add(:customer, "must be the customer of the booking")
end
end

def provider_must_match_booking
return unless booking && provider

unless booking.provider_id == provider_id
  errors.add(:provider, "must be the provider of the booking")
end
end

def refresh_provider_rating
  ProviderRatingJob.perform_later(provider_id)
end
end

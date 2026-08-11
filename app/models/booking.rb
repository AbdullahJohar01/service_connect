class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :provider, class_name: "ProviderProfile"
  belongs_to :service_category
  belongs_to :address
  has_one :review, dependent: :destroy

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2,
    confirmed: 3,
    in_progress: 4,
    completed: 5,
    cancelled: 6
  }

  validates :scheduled_at, presence: true
  validates :estimated_duration, numericality: { greater_than: 0 }
  validates :customer_description, presence: true
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }
end

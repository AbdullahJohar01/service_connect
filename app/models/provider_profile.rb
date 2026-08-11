class ProviderProfile < ApplicationRecord
  belongs_to :user
  has_many :availabilities, dependent: :destroy

  enum :approval_status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validates :business_name, presence: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }
  validates :hourly_rate, numericality: { greater_than: 0 }
end

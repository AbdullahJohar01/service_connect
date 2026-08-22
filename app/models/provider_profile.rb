class ProviderProfile < ApplicationRecord
  belongs_to :user

  has_one_attached :profile_image
  has_many_attached :identity_documents
  has_many_attached :professional_certificates

  has_many :provider_services, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :bookings,
           foreign_key: :provider_id,
           dependent: :destroy
  has_many :reviews,
           foreign_key: :provider_id,
           dependent: :destroy

  enum :approval_status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validates :business_name, presence: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }
  validates :hourly_rate, numericality: { greater_than: 0 }

  validate :profile_image_format

  private

  def profile_image_format
    return unless profile_image.attached?

    acceptable_types = [
      "image/jpeg",
      "image/png",
      "image/webp"
    ]

    unless acceptable_types.include?(profile_image.content_type)
      errors.add(
        :profile_image,
        "must be a JPEG, PNG, or WebP image"
      )
    end

    if profile_image.byte_size > 5.megabytes
      errors.add(
        :profile_image,
        "must be less than 5 MB"
      )
    end
  end
end

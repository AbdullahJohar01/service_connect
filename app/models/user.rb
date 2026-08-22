class User < ApplicationRecord
  has_secure_password

  has_one :customer_profile, dependent: :destroy
  has_one :provider_profile, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :reviews, foreign_key: :customer_id, dependent: :destroy
  has_many :messages, foreign_key: :sender_id, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :customer_bookings,
            class_name: "Booking",
            foreign_key: :customer_id,
            dependent: :destroy
  has_many :booking_status_histories,
            foreign_key: :changed_by_id,
            dependent: :destroy

  enum :role, {
    customer: 0,
    provider: 1,
    admin: 2
  }

  enum :status, {
    pending: 0,
    active: 1,
    suspended: 2,
    rejected: 3
  }

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email,
            presence: true,
            uniqueness: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :phone_number, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end

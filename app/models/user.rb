class User < ApplicationRecord
  has_secure_password

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
end

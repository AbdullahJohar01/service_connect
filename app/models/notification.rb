class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  validates :notification_type, presence: true
  validates :message, presence: true
end

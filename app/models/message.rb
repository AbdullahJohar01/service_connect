class Message < ApplicationRecord
  belongs_to :booking
  belongs_to :sender, class_name: "User"

  validates :content, presence: true
end

class BookingStatusHistory < ApplicationRecord
  belongs_to :booking
  belongs_to :changed_by, class_name: "User"

  validates :new_status, presence: true
end

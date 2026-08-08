class ProviderProfile < ApplicationRecord
  belongs_to :user

  enum :approval_status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }
end

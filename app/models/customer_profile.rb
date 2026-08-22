class CustomerProfile < ApplicationRecord
  belongs_to :user
  has_many_attached :problem_images
  has_many_attached :supporting_documents
end

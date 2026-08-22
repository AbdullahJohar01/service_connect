# frozen_string_literal: true

module Types
  class ServiceCategoryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :active, Boolean, null: false
  end
end

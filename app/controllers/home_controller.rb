class HomeController < ApplicationController
  def index
    @service_categories = ServiceCategory
      .where(active: true)
      .order(:name)
  end
end

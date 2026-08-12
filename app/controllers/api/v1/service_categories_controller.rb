class Api::V1::ServiceCategoriesController < Api::V1::BaseController
  def index
    categories = ServiceCategory.where(active: true)

    render json: {
      service_categories: categories.map { |category| service_category_json(category) }
    }
  end

  def show
    category = ServiceCategory.find_by(id: params[:id])

    unless category
      render json: { error: "Service category not found" }, status: :not_found
      return
    end

    render json: {
      service_category: service_category_json(category)
    }
  end

  def create
    unless current_user.admin?
      render json: { error: "Admin access required" }, status: :forbidden
      return
    end

    category = ServiceCategory.new(service_category_params)

    if category.save
      render json: {
        message: "Service category created successfully",
        service_category: service_category_json(category)
      }, status: :created
    else
      render json: {
        error: "Service category could not be created",
        errors: category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    unless current_user.admin?
      render json: { error: "Admin access required" }, status: :forbidden
      return
    end

    category = ServiceCategory.find_by(id: params[:id])

    unless category
      render json: { error: "Service category not found" }, status: :not_found
      return
    end

    if category.update(service_category_params)
      render json: {
        message: "Service category updated successfully",
        service_category: service_category_json(category)
      }
    else
      render json: {
        error: "Service category could not be updated",
        errors: category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.admin?
      render json: { error: "Admin access required" }, status: :forbidden
      return
    end

    category = ServiceCategory.find_by(id: params[:id])

    unless category
      render json: { error: "Service category not found" }, status: :not_found
      return
    end

    category.update(active: false)

    render json: {
      message: "Service category deactivated successfully"
    }
  end

  private

  def service_category_params
    params.require(:service_category).permit(
      :name,
      :description,
      :active
    )
  end

  def service_category_json(category)
    {
      id: category.id,
      name: category.name,
      description: category.description,
      active: category.active,
      created_at: category.created_at,
      updated_at: category.updated_at
    }
  end
end

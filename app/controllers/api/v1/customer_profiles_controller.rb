class Api::V1::CustomerProfilesController < Api::V1::BaseController
  before_action :require_customer
  before_action :set_customer_profile, only: [ :show, :update ]

  def show
    render json: { customer_profile: profile_json(@customer_profile) }
  end

  def create
    if current_user.customer_profile
      return render json: { error: "Customer profile already exists" }, status: :unprocessable_entity
    end

    @customer_profile = current_user.build_customer_profile(customer_profile_params)

    if @customer_profile.save
      render json: {
        message: "Customer profile created successfully",
        customer_profile: profile_json(@customer_profile)
      }, status: :created
    else
      render json: {
        errors: @customer_profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @customer_profile.update(customer_profile_params)
      render json: {
        message: "Customer profile updated successfully",
        customer_profile: profile_json(@customer_profile)
      }
    else
      render json: {
        errors: @customer_profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def require_customer
    unless current_user.customer?
      render json: { error: "Customer access required" }, status: :forbidden
    end
  end

  def set_customer_profile
    @customer_profile = current_user.customer_profile

    unless @customer_profile
      render json: { error: "Customer profile not found" }, status: :not_found
    end
  end

  def customer_profile_params
    params.require(:customer_profile).permit(
      :date_of_birth,
      :preferred_language
    )
  end

  def profile_json(profile)
    {
      id: profile.id,
      user_id: profile.user_id,
      date_of_birth: profile.date_of_birth,
      preferred_language: profile.preferred_language,
      created_at: profile.created_at,
      updated_at: profile.updated_at
    }
  end
end

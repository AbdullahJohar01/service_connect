class Api::V1::AddressesController < Api::V1::BaseController
  before_action :set_address, only: [ :show, :update, :destroy, :set_default ]

  def index
    addresses = current_user.addresses

    render json: {
      addresses: addresses.map { |address| address_json(address) }
    }
  end

  def show
    render json: {
      address: address_json(@address)
    }
  end

  def create
    address = current_user.addresses.new(address_params)

    if address.save
      render json: {
        message: "Address created successfully",
        address: address_json(address)
      }, status: :created
    else
      render json: {
        error: "Address could not be created",
        errors: address.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      render json: {
        message: "Address updated successfully",
        address: address_json(@address)
      }
    else
      render json: {
        error: "Address could not be updated",
        errors: @address.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy

    render json: {
      message: "Address deleted successfully"
    }
  end

  def set_default
    Address.transaction do
      current_user.addresses.where.not(id: @address.id).update_all(is_default: false, updated_at: Time.current)
      @address.update!(is_default: true)
    end

    render json: { message: "Default address updated successfully", address: address_json(@address) }
  end

  private

  def set_address
    @address = current_user.addresses.find_by(id: params[:id])

    return if @address

    render json: { error: "Address not found" }, status: :not_found
  end

  def address_params
    params.require(:address).permit(
      :label,
      :street,
      :city,
      :postal_code,
      :latitude,
      :longitude,
      :is_default
    )
  end

  def address_json(address)
    {
      id: address.id,
      user_id: address.user_id,
      label: address.label,
      street: address.street,
      city: address.city,
      postal_code: address.postal_code,
      latitude: address.latitude,
      longitude: address.longitude,
      is_default: address.is_default,
      created_at: address.created_at,
      updated_at: address.updated_at
    }
  end
end

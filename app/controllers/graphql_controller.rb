# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_forgery_protection

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user
    }

    result = ServiceConnectSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def current_user
    header = request.headers["Authorization"]

    return nil if header.blank?

    token = header.split(" ").last
    decoded = JwtService.decode(token)

    return nil if decoded.nil?

    User.active.find_by(id: decoded["user_id"])
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: {
      errors: [
        {
          message: error.message,
          backtrace: error.backtrace
        }
      ],
      data: {}
    }, status: :internal_server_error
  end
end

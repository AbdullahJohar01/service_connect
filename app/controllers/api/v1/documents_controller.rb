class Api::V1::DocumentsController < Api::V1::BaseController
  def create
    attachment = permitted_attachment
    return render(json: { error: "Unsupported document target" }, status: :unprocessable_entity) unless attachment

    files = Array(params[:files] || params[:file]).compact
    return render(json: { error: "At least one file is required" }, status: :unprocessable_entity) if files.empty? || files.size > 5
    return render(json: { error: "Files must be PDF, JPEG, PNG, or WebP and smaller than 10 MB" }, status: :unprocessable_entity) unless files.all? { |file| valid_file?(file) }

    attachment.attach(files)
    render json: { message: "Documents uploaded successfully", count: attachment.count }, status: :created
  end

  private

  def permitted_attachment
    case params[:kind]
    when "identity_documents" then current_user.provider? && current_user.provider_profile&.identity_documents
    when "professional_certificates" then current_user.provider? && current_user.provider_profile&.professional_certificates
    when "problem_images" then current_user.customer? && current_user.customer_profile&.problem_images
    when "supporting_documents" then current_user.customer? && current_user.customer_profile&.supporting_documents
    end
  end

  def valid_file?(file)
    [ "application/pdf", "image/jpeg", "image/png", "image/webp" ].include?(file.content_type) && file.size <= 10.megabytes
  end
end

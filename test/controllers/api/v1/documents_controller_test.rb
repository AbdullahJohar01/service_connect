require "test_helper"

class Api::V1::DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = users(:two)
    @customer = users(:one)

    @provider_token = JwtService.encode(@provider.id)
    @customer_token = JwtService.encode(@customer.id)
  end

  test "provider can upload identity documents" do
    file = fixture_file_upload(
      "test/fixtures/files/test.pdf",
      "application/pdf"
    )

    assert_difference(
      -> { @provider.provider_profile.identity_documents.count },
      1
    ) do
      post "/api/v1/documents/identity_documents",
           params: { file: file },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "Documents uploaded successfully", body["message"]
    assert_equal 1, body["count"]
  end

  test "provider can upload professional certificates" do
    file = fixture_file_upload(
      "test/fixtures/files/test.pdf",
      "application/pdf"
    )

    assert_difference(
      -> { @provider.provider_profile.professional_certificates.count },
      1
    ) do
      post "/api/v1/documents/professional_certificates",
           params: { file: file },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "Documents uploaded successfully", body["message"]
    assert_equal 1, body["count"]
  end

  test "customer can upload problem image" do
    file = fixture_file_upload(
      "test/fixtures/files/test.png",
      "image/png"
    )

    assert_difference(
      -> { @customer.customer_profile.problem_images.count },
      1
    ) do
      post "/api/v1/documents/problem_images",
           params: { file: file },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "Documents uploaded successfully", body["message"]
    assert_equal 1, body["count"]
  end

  test "customer can upload supporting document" do
    file = fixture_file_upload(
      "test/fixtures/files/test.pdf",
      "application/pdf"
    )

    assert_difference(
      -> { @customer.customer_profile.supporting_documents.count },
      1
    ) do
      post "/api/v1/documents/supporting_documents",
           params: { file: file },
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "Documents uploaded successfully", body["message"]
    assert_equal 1, body["count"]
  end

  test "rejects unsupported document target" do
    file = fixture_file_upload(
      "test/fixtures/files/test.pdf",
      "application/pdf"
    )

    post "/api/v1/documents/unknown",
         params: { file: file },
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "Unsupported document target", body["error"]
  end

  test "rejects request without a file" do
    post "/api/v1/documents/identity_documents",
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "At least one file is required", body["error"]
  end

  test "rejects unsupported file type" do
    file = fixture_file_upload(
      "test/fixtures/files/test.txt",
      "text/plain"
    )

    post "/api/v1/documents/identity_documents",
         params: { file: file },
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal(
      "Files must be PDF, JPEG, PNG, or WebP and smaller than 10 MB",
      body["error"]
    )
  end

  test "provider cannot upload customer documents" do
    file = fixture_file_upload(
      "test/fixtures/files/test.pdf",
      "application/pdf"
    )

    post "/api/v1/documents/problem_images",
         params: { file: file },
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "Unsupported document target", body["error"]
  end
end

require "test_helper"

class Api::V1::ProviderProfileImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:one)
    @provider = users(:two)

    @customer_token = JwtService.encode(@customer.id)
    @provider_token = JwtService.encode(@provider.id)

    @provider_profile = @provider.provider_profile
  end

  test "provider can upload a profile image" do
    file = fixture_file_upload(
      "test/fixtures/files/test.png",
      "image/png"
    )

    assert_difference(
      -> { ActiveStorage::Attachment.where(
        record: @provider_profile,
        name: "profile_image"
      ).count },
      1
    ) do
      post "/api/v1/provider-profile/image",
           params: { file: file },
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }
    end

    assert_response :success

    @provider_profile.reload

    assert @provider_profile.profile_image.attached?

    data = JSON.parse(response.body)

    assert_equal(
      "Profile image uploaded successfully",
      data["message"]
    )

    assert data["profile_image_url"].present?
  end

  test "provider can delete their profile image" do
    file = fixture_file_upload(
      "test/fixtures/files/test.png",
      "image/png"
    )

    @provider_profile.profile_image.attach(file)

    assert @provider_profile.profile_image.attached?

    delete "/api/v1/provider-profile/image",
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }

    assert_response :success

    @provider_profile.reload

    assert_not @provider_profile.profile_image.attached?

    data = JSON.parse(response.body)

    assert_equal(
      "Profile image deleted successfully",
      data["message"]
    )
  end

  test "customer cannot upload a provider profile image" do
    file = fixture_file_upload(
      "test/fixtures/files/test.png",
      "image/png"
    )

    post "/api/v1/provider-profile/image",
         params: { file: file },
         headers: {
           "Authorization" => "Bearer #{@customer_token}"
         }

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal(
      "Only providers can upload a profile image",
      data["error"]
    )

    assert_not @provider_profile.profile_image.attached?
  end

  test "customer cannot delete a provider profile image" do
    delete "/api/v1/provider-profile/image",
           headers: {
             "Authorization" => "Bearer #{@customer_token}"
           }

    assert_response :forbidden

    data = JSON.parse(response.body)

    assert_equal(
      "Only providers can delete a profile image",
      data["error"]
    )
  end

  test "provider cannot upload without a file" do
    post "/api/v1/provider-profile/image",
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :unprocessable_content

    data = JSON.parse(response.body)

    assert_equal(
      "Profile image is required",
      data["error"]
    )
  end

  test "provider gets not found when profile does not exist" do
    @provider.provider_profile.destroy!

    post "/api/v1/provider-profile/image",
         params: {
           file: fixture_file_upload(
             "test/fixtures/files/test.png",
             "image/png"
           )
         },
         headers: {
           "Authorization" => "Bearer #{@provider_token}"
         }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal(
      "Provider profile not found",
      data["error"]
    )
  end

  test "provider cannot delete image when no image exists" do
    delete "/api/v1/provider-profile/image",
           headers: {
             "Authorization" => "Bearer #{@provider_token}"
           }

    assert_response :not_found

    data = JSON.parse(response.body)

    assert_equal(
      "No profile image found",
      data["error"]
    )
  end
end

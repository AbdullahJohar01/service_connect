require "test_helper"

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  test "suspended users cannot authenticate GraphQL requests" do
    user = users(:one)
    token = JwtService.encode(user.id)
    user.update!(status: :suspended)

    post "/graphql", params: { query: "{ currentUser { id } }" }, headers: { "Authorization" => "Bearer #{token}" }

    assert_response :success
    assert_nil JSON.parse(response.body).dig("data", "currentUser")
  end
end

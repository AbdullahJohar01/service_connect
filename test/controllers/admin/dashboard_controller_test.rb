require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = User.create!(
        first_name: "Test",
        last_name: "Admin",
        email: "admin_test@example.com",
        password: "password123",
        phone_number: "03000000004",
        role: :admin,
        status: :active
      )

      @pending_provider_user = User.create!(
        first_name: "Pending",
        last_name: "Provider",
        email: "pending_provider@example.com",
        password: "password123",
        phone_number: "03000000005",
        role: :provider,
        status: :active
      )

      @pending_provider = ProviderProfile.create!(
        user: @pending_provider_user,
        business_name: "Pending Electrical Services",
        description: "Electrical repair and installation services",
        experience_years: 4,
        hourly_rate: 1400,
        approval_status: :pending,
        average_rating: 0,
        total_reviews: 0
      )

      @suspended_user = User.create!(
        first_name: "Suspended",
        last_name: "Customer",
        email: "suspended_customer@example.com",
        password: "password123",
        phone_number: "03000000006",
        role: :customer,
        status: :suspended
      )
    end

    test "should redirect non-admin user to root" do
      post login_path, params: {
        email: "customer_test@example.com",
        password: "password123"
      }

      assert_redirected_to root_path

      get admin_dashboard_path

      assert_redirected_to root_path
    end

    test "should show dashboard for admin" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      assert_redirected_to root_path

      get admin_dashboard_path

      assert_response :success
      assert_select "h1", "Admin Dashboard"
      assert_select "h2", /Pending Providers/
      assert_select "h2", /Approved Providers/
      assert_select "h2", /Rejected Providers/
      assert_select "h2", "Users"
      assert_select "h2", "Activity log"
    end

    test "should display pending provider" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      get admin_dashboard_path

      assert_response :success
      assert_select "h3", "Pending Electrical Services"
      assert_select "p", /pending_provider@example.com/
    end

    test "admin should approve pending provider" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      assert_difference -> {
        ActivityLog.where(
          action: "provider.approved",
          subject: @pending_provider
        ).count
      }, 1 do
        patch admin_approve_provider_path(@pending_provider)
      end

      assert_redirected_to admin_dashboard_path

      @pending_provider.reload

      assert @pending_provider.approved?
    end

    test "admin should reject pending provider" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      assert_difference -> {
        ActivityLog.where(
          action: "provider.rejected",
          subject: @pending_provider
        ).count
      }, 1 do
        patch admin_reject_provider_path(
          @pending_provider
        ), params: {
          rejection_reason: "Required documents are incomplete."
        }
      end

      assert_redirected_to admin_dashboard_path

      @pending_provider.reload

      assert @pending_provider.rejected?
      assert_equal(
        "Required documents are incomplete.",
        @pending_provider.rejection_reason
      )
    end

    test "admin should suspend another user" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      patch admin_suspend_user_path(@suspended_user)

      assert_redirected_to admin_dashboard_path

      @suspended_user.reload

      assert @suspended_user.suspended?
    end

    test "admin should reactivate suspended user" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      patch admin_reactivate_user_path(@suspended_user)

      assert_redirected_to admin_dashboard_path

      @suspended_user.reload

      assert @suspended_user.active?
    end

    test "admin should not be able to suspend themselves" do
      post login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      patch admin_suspend_user_path(@admin)

      assert_redirected_to admin_dashboard_path

      @admin.reload

      assert @admin.active?
    end
  end
end

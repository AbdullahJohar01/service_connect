require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "formats prices in Pakistani rupees" do
    assert_equal "PKR 1,800", pkr(1800)
  end
end

# frozen_string_literal: true

require "test_helper"

class ProtectedEmailTest < ActionDispatch::IntegrationTest
  ADDRESS = HomeHelper::CONTACT_EMAIL

  test "the reset page keeps the contact address out of the HTML" do
    get "/password_resets/new"
    assert_protected_address
  end

  test "the Facebook accounts page keeps the contact address out of the HTML" do
    get "/facebook-accounts"
    assert_protected_address
    assert_select ".protected-email[data-subject=?]", "Claim my forum account"
  end

  private

  def assert_protected_address
    assert_response :success
    assert_not_includes response.body, ADDRESS
    encoded = Base64.strict_encode64(ADDRESS.reverse)
    assert_select ".protected-email[data-email=?]", encoded
    assert_select ".protected-email noscript"
  end
end

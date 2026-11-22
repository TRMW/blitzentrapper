# frozen_string_literal: true

require "test_helper"

class SignupTest < ActionDispatch::IntegrationTest
  USER_PARAMS = { login: "newfan", email: "newfan@example.com", password: "password123" }.freeze

  def signup_timer_from_form
    get "/signup"
    assert_response :success
    css_select("input[name=signup_started_at]").first["value"]
  end

  test "a person who takes a few seconds can sign up" do
    timer = signup_timer_from_form
    travel 10.seconds do
      assert_difference -> { User.count }, 1 do
        post "/users", params: { user: USER_PARAMS, signup_started_at: timer, contact_me_by_fax_only: "" }
      end
    end
    assert_redirected_to "/users/newfan"
  end

  test "filling in the hidden honeypot field blocks the signup" do
    timer = signup_timer_from_form
    travel 10.seconds do
      assert_no_difference -> { User.count } do
        post "/users", params: { user: USER_PARAMS, signup_started_at: timer, contact_me_by_fax_only: "http://spam.example" }
      end
    end
    assert_match "looked automated", response.body
  end

  test "posting the form right after loading it blocks the signup" do
    timer = signup_timer_from_form
    assert_no_difference -> { User.count } do
      post "/users", params: { user: USER_PARAMS, signup_started_at: timer }
    end
    assert_match "looked automated", response.body
  end

  test "posting without the signup page's timer blocks the signup" do
    assert_no_difference -> { User.count } do
      post "/users", params: { user: USER_PARAMS }
    end
    assert_match "looked automated", response.body

    assert_no_difference -> { User.count } do
      post "/users", params: { user: USER_PARAMS, signup_started_at: "1" }
    end
  end

  test "profile website links are nofollow and only http(s)" do
    user = User.create!(login: "linker", email: "linker@example.com", password: "password123", url: "example.com")
    get "/users/linker"
    assert_select "a[href='http://example.com'][rel='nofollow ugc noopener']", "example.com"

    user.update_column(:url, "javascript:alert(1)")
    get "/users/linker"
    assert_select "a[href^='javascript']", 0
  end

  test "a profile website must be a web address" do
    user = User.new(login: "badlink", email: "badlink@example.com", password: "password123", url: "javascript:alert(1)")
    assert_not user.valid?
    assert user.errors[:url].any?

    user.url = "https://example.com/me"
    assert user.valid?
  end
end

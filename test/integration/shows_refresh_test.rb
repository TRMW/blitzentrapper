require "test_helper"
require "minitest/mock"

class ShowsRefreshTest < ActionDispatch::IntegrationTest
  test "only admins can import shows from Bandsintown" do
    log_in_as("fan")

    Show.stub(:get_shows, -> { flunk "non-admins must not trigger an import" }) do
      post shows_refresh_path
    end

    assert_redirected_to root_path
  end

  test "a Bandsintown error sends the admin back with a message instead of a 500" do
    log_in_as("Matt")
    forbidden = OpenURI::HTTPError.new("403 Forbidden", StringIO.new)

    Show.stub(:get_shows, -> { raise forbidden }) do
      post shows_refresh_path
    end

    assert_redirected_to shows_admin_path
    assert_match "403 Forbidden", flash[:alert]
  end

  test "a successful import shows the summary" do
    log_in_as("Matt")

    Show.stub(:get_shows, "2 new shows") do
      post shows_refresh_path
    end

    assert_redirected_to shows_url(refresh: true)
    assert_equal "2 new shows", flash[:notice]
  end

  private

  def log_in_as(login)
    user = User.new(login: login, password: "secret123")
    user.reset_persistence_token
    user.save!(validate: false)
    post "/user_session", params: { user_session: { login: login, password: "secret123" } }
  end
end

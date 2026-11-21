require "test_helper"

# Loads each public page once so framework upgrades that break a view,
# helper or query show up in CI. Keep these shallow; feature behavior
# belongs in its own test.
class PageSmokeTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(login: "fan", password: "secret123")
    @user.reset_persistence_token
    @user.save!(validate: false)

    @topic = Topic.create!(title: "Favorite album", posts_attributes: [ { body: "Furr, obviously", user: @user } ])
    @upcoming = Show.create!(city: "Portland", region: "OR", venue: "Doug Fir", date: Date.today + 30, status: "available")
    @past = Show.create!(city: "Paris", country: "France", venue: "La Cigale", date: Date.new(2024, 5, 4))
    @record = Record.new(title: "Furr", release_date: Date.new(2008, 9, 23))
    @record.cover.attach(io: File.open(Rails.root.join("app/assets/images/bg-button.gif")), filename: "furr.gif")
    @record.save!
  end

  test "forum index and a topic" do
    get "/"
    assert_response :success
    assert_select "a[href=?]", topic_path(@topic)

    get topic_path(@topic)
    assert_response :success
    assert_match "Furr, obviously", response.body
  end

  test "upcoming shows, archive and a past show" do
    get shows_path
    assert_response :success
    assert_match "Doug Fir", response.body

    get archive_index_path
    assert_response :success

    get show_year_path(2024)
    assert_response :success
    assert_match "La Cigale", response.body

    get show_path(@past)
    assert_response :success
  end

  test "records index and a record" do
    get records_path
    assert_response :success
    assert_match "Furr", response.body

    get record_path(@record)
    assert_response :success
  end

  test "resized record covers render" do
    get records_path
    variant_url = css_select(".record img").first["src"]

    get variant_url
    assert_response :redirect, "the cover variant should resize and redirect to the file"
  end

  test "user profile" do
    get user_path(@user)
    assert_response :success
  end

  test "static pages" do
    [ contact_path, videos_path, login_path, signup_path ].each do |path|
      get path
      assert_response :success, "#{path} should load"
    end
  end

  test "atom feed" do
    get posts_path(format: :atom)
    assert_response :success
    assert_match "Furr, obviously", response.body
  end

  test "unknown pages are 404s" do
    get "/no-such-page"
    assert_response :not_found
  end
end

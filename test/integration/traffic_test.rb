require "test_helper"

class TrafficTest < ActionDispatch::IntegrationTest
  BROWSER = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36".freeze

  test "counts a person arriving from search and a crawler" do
    get "/", headers: { "User-Agent" => BROWSER, "Referer" => "https://www.google.com/", "CF-IPCountry" => "DE" }
    get "/", headers: { "User-Agent" => "Mozilla/5.0 (compatible; GPTBot/1.2; +https://openai.com/gptbot)" }

    today = Date.current
    assert_equal 1, count("agent", "Person", today)
    assert_equal 1, count("agent", "GPTBot (OpenAI)", today)
    assert_equal 1, count("source", "Search", today)
    assert_equal 1, count("referrer", "Google", today)
    assert_equal 1, count("country", "DE", today)
    assert_equal 1, count("landing", "/", today)
  end

  test "adds to existing counters" do
    2.times { get "/", headers: { "User-Agent" => BROWSER } }

    assert_equal 2, count("source", "Direct", Date.current)
    assert_equal 2, count("page", "/", Date.current)
  end

  test "doesn't count redirects" do
    get "/home", headers: { "User-Agent" => BROWSER }
    get "/account", headers: { "User-Agent" => BROWSER }

    assert_equal 0, TrafficCount.count
  end

  test "a counting failure doesn't break the page" do
    TrafficCount.stub(:increment, ->(*) { raise ActiveRecord::StatementInvalid, "boom" }) do
      get "/", headers: { "User-Agent" => BROWSER }
    end

    assert_response :success
  end

  test "the dashboard is for admins only" do
    log_in_as("fan")
    get traffic_path

    assert_redirected_to root_path
  end

  test "the dashboard shows sources, sites, countries and crawlers" do
    TrafficCount.increment({ "agent" => "Person", "page" => "/shows", "source" => "Social",
                             "referrer" => "Reddit", "landing" => "/shows", "country" => "FR" }, day: Date.current - 1)
    TrafficCount.increment({ "agent" => "Turnitin" })
    log_in_as("Matt")

    get traffic_path(days: 30)

    assert_response :success
    assert_select "h1", "Where traffic comes from"
    assert_match "Reddit", response.body
    assert_match "Social", response.body
    assert_select "[data-region=FR]"
    assert_match "Turnitin", response.body
  end

  private

  def count(dimension, value, day)
    TrafficCount.find_by(dimension: dimension, value: value, day: day)&.count.to_i
  end

  def log_in_as(login)
    user = User.new(login: login, password: "secret123")
    user.reset_persistence_token
    user.save!(validate: false)
    post "/user_session", params: { user_session: { login: login, password: "secret123" } }
  end
end

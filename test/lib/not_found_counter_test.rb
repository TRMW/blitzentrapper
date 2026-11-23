require "test_helper"
require "not_found_counter"

class NotFoundCounterTest < ActiveSupport::TestCase
  BROWSER = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36".freeze

  def request(path, status: 404, user_agent: BROWSER, referrer: nil, cookie: nil, method: "GET")
    app = ->(_env) { [ status, {}, [ "" ] ] }
    env = Rack::MockRequest.env_for("https://forum.blitzentrapper.net#{path}", method: method,
      "HTTP_USER_AGENT" => user_agent, "HTTP_REFERER" => referrer, "HTTP_COOKIE" => cookie,
      "HTTP_ACCEPT_LANGUAGE" => "en-US")
    NotFoundCounter.new(app).call(env)
  end

  def count(dimension, value)
    TrafficCount.find_by(dimension: dimension, value: value, day: Date.current)&.count.to_i
  end

  test "counts a person following a broken link from our own page" do
    request("/shows/480", referrer: "https://forum.blitzentrapper.net/forum/old-thread?page=2")

    assert_equal 1, count("not_found_agent", "Person")
    assert_equal 1, count("not_found_page", "/shows/480")
    assert_equal 1, count("not_found_link", "/forum/old-thread → /shows/480")
  end

  test "names other sites and crawlers" do
    request("/old-page", referrer: "https://www.google.com/")
    request("/wp-login.php", user_agent: "Mozilla/5.0 (compatible; GPTBot/1.2)")

    assert_equal 1, count("not_found_link", "Google → /old-page")
    assert_equal 1, count("not_found_agent", "GPTBot (OpenAI)")
    assert_equal 1, count("not_found_bot_page", "/wp-login.php")
  end

  test "ignores found pages, assets, posts and admins" do
    request("/forum", status: 200)
    request("/assets/missing.css")
    request("/favicon.ico")
    request("/forum/search", method: "POST")
    request("/shows/480", cookie: "exclude_from_traffic=1")

    assert_equal 0, TrafficCount.count
  end

  test "passes the response through even if counting fails" do
    TrafficCount.stub(:increment, ->(*) { raise "boom" }) do
      assert_equal 404, request("/nope").first
    end
  end
end

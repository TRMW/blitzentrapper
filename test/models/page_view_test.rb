require "test_helper"

class PageViewTest < ActiveSupport::TestCase
  CHROME = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36".freeze
  HOST = "forum.blitzentrapper.net".freeze

  def view(user_agent: CHROME, referrer: nil, path: "/forum/furr", country: "US")
    PageView.new(user_agent: user_agent, referrer: referrer, path: path, host: HOST, country: country)
  end

  test "names well-known crawlers" do
    assert_equal "GPTBot (OpenAI)", view(user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.2; +https://openai.com/gptbot)").agent
    assert_equal "Meta crawler", view(user_agent: "meta-webindexer/1.1 (+https://developers.facebook.com/docs/sharing/webmasters/crawler)").agent
    assert_equal "Meta crawler", view(user_agent: "Mozilla/5.0 (compatible; meta-externalagent/1.1 (+https://developers.facebook.com/docs/sharing/webmasters/crawler))").agent
    assert_equal "Googlebot", view(user_agent: "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)").agent
    assert_equal "Baiduspider", view(user_agent: "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)").agent
    assert_equal "Turnitin", view(user_agent: "Turnitin (https://bit.ly/2UvnfoQ)").agent
    assert_equal "Zapier", view(user_agent: "Zapier").agent
  end

  test "treats unknown non-browser clients as bots and browsers as people" do
    assert_equal "Other bot", view(user_agent: "python-requests/2.32").agent
    assert_equal "Other bot", view(user_agent: "").agent
    assert_equal "Other bot", view(user_agent: "Mozilla/5.0 (compatible; SomeCrawler/1.0)").agent
    assert_equal "Person", view.agent
    assert_equal "Person", view(user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Mobile/15E148 Safari/604.1").agent
  end

  test "groups referrers into search, social, other sites and direct" do
    assert_equal [ "Search", "Google" ], [ view(referrer: "https://www.google.com/").source, view(referrer: "https://www.google.com/").referrer_name ]
    assert_equal [ "Search", "Google" ], [ view(referrer: "https://www.google.co.uk/").source, view(referrer: "https://www.google.co.uk/").referrer_name ]
    assert_equal [ "Search", "DuckDuckGo" ], [ view(referrer: "https://duckduckgo.com/").source, view(referrer: "https://duckduckgo.com/").referrer_name ]
    assert_equal [ "Social", "Facebook" ], [ view(referrer: "https://l.facebook.com/l.php?u=x").source, view(referrer: "https://l.facebook.com/").referrer_name ]
    assert_equal [ "Social", "Reddit" ], [ view(referrer: "https://old.reddit.com/r/indieheads").source, view(referrer: "https://old.reddit.com/").referrer_name ]
    assert_equal [ "Social", "X / Twitter" ], [ view(referrer: "https://t.co/abc").source, view(referrer: "https://t.co/abc").referrer_name ]
    assert_equal [ "Other sites", "pitchfork.com" ], [ view(referrer: "https://pitchfork.com/reviews/").source, view(referrer: "https://pitchfork.com/").referrer_name ]
    assert_equal "Direct", view(referrer: nil).source
    assert_equal "Direct", view(referrer: "not a url").source
  end

  test "counts an arrival with its source, site, landing page and country" do
    counters = view(referrer: "https://www.google.com/", path: "/shows/623").counters

    assert_equal({ "agent" => "Person", "page" => "/shows/623", "source" => "Search",
                   "referrer" => "Google", "landing" => "/shows/623", "country" => "US" }, counters)
  end

  test "counts a click within the site as a page view only" do
    counters = view(referrer: "https://forum.blitzentrapper.net/forum", path: "/forum/furr").counters
    assert_equal({ "agent" => "Person", "page" => "/forum/furr" }, counters)

    counters = view(referrer: "https://www.blitzentrapper.net/", path: "/shows").counters
    assert_equal({ "agent" => "Person", "page" => "/shows" }, counters)
  end

  test "counts a crawler by name only" do
    assert_equal({ "agent" => "Googlebot" }, view(user_agent: "Googlebot/2.1", referrer: "https://www.google.com/").counters)
  end

  test "direct arrivals have no referrer, and a missing country is Unknown" do
    counters = view(country: nil).counters

    assert_equal "Direct", counters["source"]
    assert_not counters.key?("referrer")
    assert_equal "Unknown", counters["country"]
  end
end

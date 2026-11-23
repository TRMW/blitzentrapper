# Classifies one page view for the traffic dashboard: is it a person or a
# crawler, and if it's a person arriving from elsewhere, where from (search,
# social, another site, or direct) and which country. Nothing here keeps the
# visitor's IP address; referring links are stored without their query string
# (except a search engine's search terms) and only as counts (see TrafficCount).
class PageView
  # Crawlers and automated clients, matched against the User-Agent in order.
  # The first matching label wins.
  BOTS = [
    [ "Googlebot", /Googlebot|Google-InspectionTool|GoogleOther|Storebot-Google|AdsBot-Google|Mediapartners-Google/i ],
    [ "Bingbot", /bingbot|BingPreview|msnbot/i ],
    [ "GPTBot (OpenAI)", /GPTBot|ChatGPT-User|OAI-SearchBot/i ],
    [ "ClaudeBot (Anthropic)", /ClaudeBot|Claude-User|Claude-SearchBot|anthropic-ai/i ],
    [ "PerplexityBot", /Perplexity/i ],
    [ "Meta crawler", /meta-externalagent|meta-externalfetcher|meta-webindexer|facebookexternalhit|facebookcatalog/i ],
    [ "Applebot", /Applebot/i ],
    [ "Amazonbot", /Amazonbot/i ],
    [ "Bytespider (TikTok)", /Bytespider|TikTokSpider/i ],
    [ "Baiduspider", /Baiduspider/i ],
    [ "YandexBot", /Yandex/i ],
    [ "DuckDuckBot", /DuckDuckBot|DuckAssistBot/i ],
    [ "Turnitin", /Turnitin/i ],
    [ "AhrefsBot", /AhrefsBot/i ],
    [ "SemrushBot", /SemrushBot/i ],
    [ "PetalBot", /PetalBot/i ],
    [ "CCBot (Common Crawl)", /CCBot/i ],
    [ "Zapier", /Zapier/i ],
    [ "Feed reader", /Feedly|Inoreader|NewsBlur|Feedbin|FreshRSS|Tiny Tiny RSS|NetNewsWire|feedparser|\bRSS\b/i ],
    [ "Other bot", /bot\b|bot\/|crawl|spider|slurp|scrap|fetch|archiver|python|curl|wget|httpclient|http-client|okhttp|go-http|java\/|ruby|node-fetch|axios|headless|phantom|lighthouse|monitor|uptime|preview/i ]
  ].freeze

  SEARCH_ENGINES = {
    "google" => "Google", "bing" => "Bing", "duckduckgo" => "DuckDuckGo",
    "yahoo" => "Yahoo", "ecosia" => "Ecosia", "baidu" => "Baidu",
    "yandex" => "Yandex", "search.brave" => "Brave Search",
    "startpage" => "Startpage", "qwant" => "Qwant", "kagi" => "Kagi",
    "naver" => "Naver", "chatgpt" => "ChatGPT", "perplexity" => "Perplexity"
  }.freeze

  SOCIAL_SITES = {
    "facebook" => "Facebook", "fb.me" => "Facebook", "instagram" => "Instagram",
    "t.co" => "X / Twitter", "twitter" => "X / Twitter", "x.com" => "X / Twitter",
    "reddit" => "Reddit", "youtube" => "YouTube", "youtu.be" => "YouTube",
    "tiktok" => "TikTok", "threads" => "Threads", "bsky" => "Bluesky",
    "mastodon" => "Mastodon", "linkedin" => "LinkedIn", "pinterest" => "Pinterest",
    "tumblr" => "Tumblr"
  }.freeze

  # Networks of cloud and hosting companies (matched against the IP's network
  # name). People don't browse from these; scrapers that pretend to be a
  # browser do. Apple's iCloud Private Relay exits through Akamai, Cloudflare
  # and Fastly, so those are deliberately not listed.
  CLOUD_NETWORKS = /amazon|google llc|google cloud|microsoft|tencent|alibaba|aliyun|huawei|digitalocean|ovh|hetzner|linode|oracle|vultr|choopa|contabo|scaleway|leaseweb|m247|datacamp|hostinger|zenlayer|ucloud|baidu|byteplus|bytedance|kingsoft|hostroyale|hostpapa|ionos|colocrossing|psychz|servers\.com|hostwinds|kamatera/i

  # Browser versions older than these are years out of date (Chrome 110 and
  # Firefox 110 are from early 2023, iOS/Safari 15 from 2021). Real visitors
  # almost never run them; scrapers copy old user agents.
  MIN_VERSIONS = { %r{Chrome/(\d+)} => 110, %r{Firefox/(\d+)} => 110, /iPhone OS (\d+)_/ => 15, %r{Version/(\d+)[.\d]* (Mobile/\S+ )?Safari} => 15 }.freeze

  # Query parameters that hold the search terms on search engines that still
  # pass them along (Bing and Yahoo sometimes do; Google never does).
  SEARCH_TERM_PARAMS = %w[q p query text wd word keyword].freeze

  # Our own hosts; a referrer from one of these is a click within the site.
  OWN_HOST = /(\A|\.)blitzentrapper\.(net|com)\z/

  attr_reader :user_agent, :referrer, :path

  # country: a two-letter code if a proxy already supplied one (Cloudflare's
  # CF-IPCountry); otherwise it's looked up from ip, only for arrivals.
  # accept_language: the Accept-Language header; every real browser sends it.
  # Pass nil to skip that check (e.g. for a feed).
  # session_cookie: whether the request carried the site's session cookie,
  # which every page sets (the CSRF token in the layout); nil skips the check.
  def initialize(user_agent:, referrer:, path:, host: nil, ip: nil, country: nil, accept_language: :unchecked, session_cookie: nil)
    @accept_language = accept_language
    @session_cookie = session_cookie
    @user_agent = user_agent.to_s
    @referrer = referrer.to_s
    @path = path.to_s
    @host = host.to_s.downcase
    @ip = ip
    @country = country.presence unless country == "XX"
  end

  def country
    @country ||= GeoIp.country(@ip)
  end

  # "Person", or the crawler's name. Bots that send a normal browser user
  # agent are named "Hidden bot (<reason>)".
  def agent
    @agent ||= begin
      bot = BOTS.find { |_, pattern| user_agent.match?(pattern) }
      if bot
        bot.first
      elsif user_agent.blank? || !user_agent.start_with?("Mozilla/", "Opera/")
        "Other bot"
      elsif (reason = hidden_bot_reason)
        "Hidden bot (#{reason})"
      else
        "Person"
      end
    end
  end

  # Why a request with a browser user agent is probably a bot, or nil.
  def hidden_bot_reason
    if @accept_language != :unchecked && @accept_language.blank?
      "no browser headers"
    elsif outdated_browser?
      "outdated browser"
    elsif internal? && @session_cookie == false
      # A click from another of our pages always carries the cookie that
      # page set. Scrapers fake our own pages as the referrer.
      "fake link from our site"
    elsif (network = GeoIp.network(@ip)) && network.match?(CLOUD_NETWORKS)
      "cloud server: #{network.truncate(40)}"
    end
  end

  def person?
    agent == "Person"
  end

  # The referring site's host, without "www.", "m." and the like; nil when
  # there's no referrer.
  def referrer_host
    return @referrer_host if defined?(@referrer_host)
    host = URI.parse(referrer).host.to_s.downcase rescue ""
    @referrer_host = host.sub(/\A(www\d*|m|l|lm|mobile|out)\./, "").presence
  end

  # A click from another page on this site rather than a new arrival.
  def internal?
    referrer_host.present? && (referrer_host.match?(OWN_HOST) || referrer_host == @host.delete_prefix("www."))
  end

  # Where a visit came from: "Search", "Social", "Other sites" or "Direct".
  # Only meaningful for arrivals (person? && !internal?).
  def source
    if referrer_host.nil? then "Direct"
    elsif search_engine then "Search"
    elsif social_site then "Social"
    else "Other sites"
    end
  end

  # The referring site under a readable name: "Google", "Reddit", or the
  # plain host for any other site.
  def referrer_name
    search_engine || social_site || referrer_host
  end

  # The referring page as "host/path", without the query string or fragment
  # (they can carry tracking ids or personal details): "pitchfork.com/reviews/
  # albums/furr". Most sites only send their domain, so this is often just
  # the host. nil for search engines (their links never say more than the
  # engine) and when there's no referrer.
  def referrer_link
    return if referrer_host.nil? || search_engine

    uri = URI.parse(referrer)
    path = uri.path.to_s.sub(%r{/+\z}, "")
    "#{uri.host.downcase.delete_prefix("www.")}#{path}".truncate(200, omission: "")
  rescue URI::Error
    nil
  end

  # What the visitor searched for, when the search engine passed it along in
  # the referrer; nil otherwise (always for Google).
  def search_term
    return unless search_engine

    params = Rack::Utils.parse_query(URI.parse(referrer).query.to_s)
    term = SEARCH_TERM_PARAMS.lazy.map { |key| Array(params[key]).first }.find(&:present?)
    term&.unicode_normalize&.downcase&.squish&.truncate(100, omission: "")&.presence
  rescue URI::Error, ArgumentError, Encoding::CompatibilityError
    nil
  end

  # Counters to add for this page view, as { dimension => value }.
  #
  #   agent     every page view: "Person" or the crawler's name
  #   page      a person's page views, by path
  #   source    a person's arrivals: Search / Social / Other sites / Direct
  #   referrer  a person's arrivals from another site, by site
  #   referrer_link  the same, by referring page (see referrer_link)
  #   search_term    a person's arrivals from search, by search terms, when
  #                  the engine passed them along
  #   landing   the page a person arrived on
  #   country   a person's arrivals, by two-letter country code
  def counters
    counts = { "agent" => agent }
    return counts unless person?

    counts["page"] = path.truncate(200, omission: "")
    return counts if internal?

    counts["source"] = source
    counts["referrer"] = referrer_name if referrer_host
    counts["referrer_link"] = referrer_link if referrer_link
    counts["search_term"] = search_term if search_term
    counts["landing"] = counts["page"]
    counts["country"] = country || "Unknown"
    counts
  end

  private
    def outdated_browser?
      MIN_VERSIONS.any? do |pattern, minimum|
        version = user_agent[pattern, 1]
        version && version.to_i < minimum
      end
    end

    def search_engine
      match_site(SEARCH_ENGINES)
    end

    def social_site
      match_site(SOCIAL_SITES)
    end

    def match_site(sites)
      return unless referrer_host
      sites.find { |key, _| referrer_host == key || referrer_host.start_with?("#{key}.") || referrer_host.end_with?(".#{key}") || referrer_host.include?(".#{key}.") }&.last
    end
end

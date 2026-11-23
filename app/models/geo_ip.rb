require "maxmind/db"

# Looks up a visitor's country, and the network (ISP or hosting company) their
# IP address belongs to, in local copies of DB-IP's free "IP to Country Lite"
# and "IP to ASN Lite" databases (CC BY 4.0, https://db-ip.com).
# `rake geoip:download` fetches them during the build (it hooks into
# assets:precompile). Without a file, its lookups return nil: the dashboard
# shows the country as "Unknown", and bots on cloud servers are only caught by
# their other signs (see PageView#hidden_bot_reason).
module GeoIp
  DIR = Rails.root.join("db", "geoip")
  DATABASES = { country: "dbip-country-lite", asn: "dbip-asn-lite" }.freeze

  def self.country(ip)
    lookup(:country, ip)&.dig("country", "iso_code")
  end

  # The name of the network that owns the IP, e.g. "Comcast Cable
  # Communications, LLC" or "Shenzhen Tencent Computer Systems Company Limited".
  def self.network(ip)
    lookup(:asn, ip)&.dig("autonomous_system_organization")
  end

  def self.path(name)
    DIR.join("#{DATABASES.fetch(name)}.mmdb")
  end

  def self.lookup(name, ip)
    return if ip.blank?
    reader(name)&.get(ip)
  rescue IPAddr::InvalidAddressError, ArgumentError
    nil
  end

  def self.reader(name)
    @readers ||= {}
    return @readers[name] if @readers.key?(name)

    path = path(name)
    @readers[name] = (MaxMind::DB.new(path.to_s, mode: MaxMind::DB::MODE_MEMORY) if File.exist?(path))
  rescue StandardError => e
    Rails.logger.warn("GeoIp: can't read #{path}: #{e.class}: #{e.message}")
    @readers[name] = nil
  end
end

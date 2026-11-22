require "maxmind/db"

# Looks up a visitor's country from their IP address in a local copy of the
# free DB-IP "IP to Country Lite" database (CC BY 4.0, https://db-ip.com).
# `rake geoip:download` fetches it during the build (it hooks into
# assets:precompile). Without the file, lookups return nil and the dashboard
# shows the country as "Unknown".
module GeoIp
  PATH = Rails.root.join("db", "geoip", "dbip-country-lite.mmdb")

  def self.country(ip)
    return if ip.blank? || reader.nil?
    reader.get(ip)&.dig("country", "iso_code")
  rescue IPAddr::InvalidAddressError, ArgumentError
    nil
  end

  def self.reader
    return @reader if defined?(@reader)
    @reader = (MaxMind::DB.new(PATH.to_s, mode: MaxMind::DB::MODE_MEMORY) if File.exist?(PATH))
  rescue StandardError => e
    Rails.logger.warn("GeoIp: can't read #{PATH}: #{e.class}: #{e.message}")
    @reader = nil
  end
end

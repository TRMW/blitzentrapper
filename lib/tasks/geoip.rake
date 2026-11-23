require "net/http"
require "zlib"

namespace :geoip do
  desc "Download the free DB-IP country and network (ASN) databases used by the traffic dashboard"
  task download: :environment do
    FileUtils.mkdir_p(GeoIp::DIR)

    GeoIp::DATABASES.each do |name, file|
      path = GeoIp.path(name)
      # DB-IP publishes new files each month; early in a month they may not
      # be out yet, so fall back to last month's.
      [ Date.current, Date.current.prev_month ].each do |month|
        url = URI("https://download.db-ip.com/free/#{file}-#{month.strftime('%Y-%m')}.mmdb.gz")
        response = Net::HTTP.get_response(url)
        next unless response.is_a?(Net::HTTPSuccess)

        File.binwrite(path, Zlib.gunzip(response.body))
        puts "geoip: saved #{url} to #{path}"
        break
      end
      puts "geoip: no #{file} database downloaded" unless File.exist?(path)
    rescue StandardError => e
      # Never fail the build over this; the dashboard works without them.
      puts "geoip: #{file} download failed (#{e.class}: #{e.message})"
    end
  end
end

Rake::Task["assets:precompile"].enhance([ "geoip:download" ]) if Rake::Task.task_defined?("assets:precompile")

require "net/http"
require "zlib"

namespace :geoip do
  desc "Download the free DB-IP country database used by the traffic dashboard"
  task :download do
    path = Rails.root.join("db", "geoip", "dbip-country-lite.mmdb")
    FileUtils.mkdir_p(path.dirname)

    # DB-IP publishes a new file each month; early in a month it may not be
    # out yet, so fall back to last month's.
    [ Date.current, Date.current.prev_month ].each do |month|
      url = URI("https://download.db-ip.com/free/dbip-country-lite-#{month.strftime('%Y-%m')}.mmdb.gz")
      response = Net::HTTP.get_response(url)
      next unless response.is_a?(Net::HTTPSuccess)

      File.binwrite(path, Zlib.gunzip(response.body))
      puts "geoip: saved #{url} to #{path}"
      break
    end
    puts "geoip: no database downloaded; countries will show as Unknown" unless File.exist?(path)
  rescue StandardError => e
    # Never fail the build over this; the dashboard works without countries.
    puts "geoip: download failed (#{e.class}: #{e.message}); countries will show as Unknown"
  end
end

Rake::Task["assets:precompile"].enhance([ "geoip:download" ]) if Rake::Task.task_defined?("assets:precompile")

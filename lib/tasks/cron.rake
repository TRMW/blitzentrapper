task :cron => :environment do
	require 'hpricot'
	shows = Show.get_shows
	puts "Checked Blitzen Trapper Bandsintown and Sub Pop shows.  You amaze me, Matt Wright."
	
	puts "Removing stale sessions..." 
	session_count = CGI::Session::ActiveRecordStore::Session.delete_all(['updated_at &lt; ?', 1.hour.ago])
	puts "#{session_count} sessions removed."
end
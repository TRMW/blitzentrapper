task :cron => :environment do
	 require 'hpricot'
   shows = Show.get_shows
   puts "Checked Blitzen Trapper Bandsintown and Sub Pop shows.  You amaze me, Matt Wright."
end
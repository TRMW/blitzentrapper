task :cron => :environment do
   shows = Show.get_shows
   puts "Checked Blitzen Trapper Bandsintown and Sub Pop shows.  You amaze me, Matt Wright."
end
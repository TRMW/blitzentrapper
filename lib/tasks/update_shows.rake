desc "Fetch shows from Bandsintown"
task :update_shows => :environment do
	Show.get_shows
	puts "Checked Bandsintown for Blitzen Trapper shows. You amaze me, Matt Wright."
end

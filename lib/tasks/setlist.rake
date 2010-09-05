task :normalize_setlists => :environment do
	for @show in Show.all
	  	diff = 25 - @show.setlistings.length
	  diff.times do |i|
			@show.setlistings.create
		end
	end
end

task :legacy_encores => :environment do
	for show in Show.all
		i = 0
		for setlisting in show.setlistings
			if setlisting.song_id?
				i += 1
			end
		end
		if i > 20
			show.encore = i
			show.save
		end
	end
end
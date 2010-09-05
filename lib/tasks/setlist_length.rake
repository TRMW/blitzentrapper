task :setlist => :environment do
	for @show in Show.all
	  	diff = 25 - @show.setlistings.length
	  diff.times do |i|
			@show.setlistings.create
		end
	end
end
class Show < ActiveRecord::Base
  has_many :setlistings, :order => :track_number
  has_many :songs, :through => :setlistings, :order => 'setlistings.track_number'
  has_many :posts, :as => :postable, :dependent => :destroy
  accepts_nested_attributes_for :setlistings, 
  	:allow_destroy => true, 
  	:reject_if => proc { |attributes| attributes['song_id'].blank? }
  	# :reject_if => proc { |attributes| attributes['song_id'].blank? && attributes['song_attributes']['title'].blank? }
  accepts_nested_attributes_for :posts
  named_scope :by_year, lambda { |d| { :order => 'date DESC', :conditions => { :date  => d..d.end_of_year } } }
  named_scope :by_month, lambda { |d| { :order => 'date DESC', :conditions => { :date  => d..d.end_of_month } } }
  
  def past?
  	if date > Date.today then return false
  	else return true
  	end
  end
  
  def self.today_forward(limit)
  	find_all_by_festival_dupe(:order => "date", :conditions => ["date >= ? AND visible = ?", Date.today, trueshow.s], :limit => limit)
  end
  
  def self.today_backward
  	find_all_by_festival_dupe(:order => "date DESC", :conditions => ["date < ?", Date.today])
  end
  
  def self.make_visible
  	for show in Show.all
  		show.visible = true
  		show.save
  	end
  end
  
  def self.get_shows
  	# grab shows from Bandsintown API
  	bit_shows = JSON.parse(open('http://api.bandsintown.com/artists/Blitzen%20Trapper/events.json?app_id=blitzentrapper').read)
  	bit_shows.each do |received_show|
  		datetime = received_show['datetime'].split('T') #split datetime into date and time
  		@show = Show.find_or_initialize_by_date(datetime.first) # find or initialize by show day
  		
  		unless @show.manual?
	  		@show.time = datetime.last # set or update time	
	  		@show.venue = received_show['venue']['name']
	  		@show.ticket_link = received_show['ticket_url']
	  		@show.status = received_show['ticket_status']
	  		@show.city = received_show['venue']['city']
	  		@show.country = received_show['venue']['country']
	  		@show.region = received_show['venue']['region']
	  		@show.latitude = received_show['venue']['latitude']
	  		@show.longitude = received_show['venue']['longitude']
	  		@show.bit_id = received_show['id']
	  		
	  		# if previous show has same venue then this is a festival dupe
	  		# set starting show enddate and mark this one as a dupe
				if !@previous.nil? && @previous.venue == received_show['venue']['name']
					@show.festival_dupe = true
					@previous.enddate = @show.date
	  			@previous.save
	  		else
	  			@previous = @show #only increment previous if current isn't a festival dupe
				end
	  		@show.save!
  		end # end manual check
  	end # end Bandsintown loop
  	
  	# grab shows from Sub Pop's RSS feed for Blitzen Trapper shows
  	subpop_shows = Feedzirra::Feed.fetch_and_parse("http://www.subpop.com/rss/tour/blitzen_trapper")
  	subpop_shows.entries.each do |received_show|
  		show = Hpricot(received_show.summary)
  		
  		# parsing something like this: <abbr class="dtstart" title="2010-06-30T23:00:00">
  		datetime = show.at('.dtstart')['title'].split('T') #split datetime into date and time
  		@show = Show.find_or_initialize_by_date(datetime.first) # find or initialize by show day
  		
			unless @show.manual?
	  		if @show.new_record? # if this is a new show
		  		@show.time = datetime.last # set or update time
		  		
		  		# parsing something like this: <span class="location">Fillmore, The (SF), San Francisco CA</span>
		  		# let wrangling ensue!
		  		location = show.at('.location').inner_html.split(',')
		  		@show.venue = location.first # note that anything after first space is ignored ie. "The (SF)" in above example
		  	  location_chunks = location.last.strip.split(' ')
		  	  
		  	  # last chunk of array is either US state or foreign country
		  	  region_or_country = location_chunks.pop
		  	  if region_or_country.length == 2
		  	  	@show.region = region_or_country 
		  	  	@show.country = "United States"
		  	  else
		  	  	@show.country = region_or_country
		  	  	@show.region = region_or_country
		  	  end
		  	  
		  	  # some final wranging to reassemble city name from array
		  	  city = location_chunks.join(' ')
		  		@show.city = city
		  		
		  		if show.at('.description') # if Sub Pop added a description
	  				@show.notes = show.at('.description').inner_html
	  			end
	  			
	  		else # just add description (if present) to existing record
		  		if show.at('.description')
						@show.notes = show.at('.description').inner_html
					end
		  	end
	  		@show.save!
  		end # end manual check
  	end # end Sub Pop loop
	end # end get_shows!  this was epic!
	
	def self.update_show_regions
		shows = Show.find(306,305,304,303,302,301,300,299,298,297,296,295)
		for show in shows
			show.region = show.country
			show.save
		end
	end
	
	def self.import_billions_spreadsheet
		book = Spreadsheet.open 'public/blitzen-history.xls'
		sheet1 = book.worksheet 0
		sheet1.each do |row|
			logger.debug row[0]
			@show = Show.new
    	@show.date = row[0]
    	@show.venue = row[1]
    	@show.city = row[2]
    	@show.region = row[3]
    	@show.save!
  	end
	end
end
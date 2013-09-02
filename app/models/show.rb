class Show < ActiveRecord::Base
  has_many :setlistings, :order => :position, :dependent => :destroy
  has_many :songs, :through => :setlistings, :order => 'setlistings.position'
  has_many :posts, :as => :postable, :dependent => :destroy, :order => 'created_at ASC'
  validates_presence_of :city, :region, :venue, :date
  after_create :create_setlists

  accepts_nested_attributes_for :setlistings, :allow_destroy => true
  accepts_nested_attributes_for :posts

  scope :visible, :conditions => { :visible => true }
  scope :by_year, lambda { |d| { :order => 'date DESC', :conditions => ['(date >= ? AND date <= ? AND date <= ?) AND visible = ?', d, d.end_of_year, Date.today, true] } }
  scope :by_month, lambda { |d| { :order => 'date DESC', :conditions => { :date  => d..d.end_of_month, :visible => true  } } }
  scope :today_forward, :order => 'date', :conditions => ['(date >= ? OR enddate >= ?) AND visible = ? AND festival_dupe = ?', Date.today, Date.today, true, false]

  def create_setlists
    25.times do |i|
      self.setlistings.create
    end
  end

  def self.get_shows
    @saved_shows = []
    bit_shows = get_bandsintown_shows
    logger.info "Saved #{@saved_shows} shows!"
    return "Grabbed #{bit_shows.length} shows from BandsInTown and created #{@saved_shows.length} new shows."
  end # end get_shows!  this was epic!

  def self.get_archive_starting_year
    Show.by_year(Date.today.beginning_of_year).first ? Date.today.year : Date.today.year - 1
  end

  private

  def get_bandsintown_shows
    # grab shows from Bandsintown API
    bit_shows = JSON.parse(open('http://api.bandsintown.com/artists/Blitzen%20Trapper/events.json?app_id=blitzentrapper').read)
    logger.info "Grabbed #{bit_shows.length} shows from BandsInTown."
    bit_shows.each do |received_show|
      datetime = received_show['datetime'].split('T') #split datetime into date and time
      venue = received_show['venue']['name']
      show = Show.find_or_initialize_by_date_and_venue(datetime.first, venue) # find or initialize by show day and venue name

      unless show.manual?
        show.time = datetime.last # set or update time
        show.venue = venue
        show.ticket_link = received_show['ticket_url'] + '?affil_code=blitzentrapper'
        show.status = received_show['ticket_status']
        show.city = received_show['venue']['city']
        show.country = received_show['venue']['country']
        show.region = received_show['venue']['region']
        show.latitude = received_show['venue']['latitude']
        show.longitude = received_show['venue']['longitude']
        show.bit_id = received_show['id']

        # if previous show has same venue then this is a festival dupe
        # set starting show enddate and mark this one as a dupe
        # if !@previous.nil? && @previous.venue == received_show['venue']['name']
        #   show.festival_dupe = true
        #   @previous.enddate = show.date
        #   @previous.save
        # else
        #   @previous = show #only increment previous if current isn't a festival dupe
        # end

        show.save!
        @saved_shows << show.id if (show.new_record? && !@saved_shows.include?(show.id))
      end # end manual check
    end # end Bandsintown loop
    return bit_shows
  end

  def get_sub_pop_shows
    # grab shows from Sub Pop's RSS feed for Blitzen Trapper shows
    subpop_shows = Feedzirra::Feed.fetch_and_parse("http://www.subpop.com/rss/tour/blitzen_trapper")
    logger.info "Grabbed #{subpop_shows.entries.length} shows from Sub Pop."
    subpop_shows.entries.each do |received_show|
      show = Hpricot(received_show.summary)

      # parsing something like this: <abbr class="dtstart" title="2010-06-30T23:00:00">
      datetime = show.at('.dtstart')['title'].split('T') #split datetime into date and time
      show = Show.find_or_initialize_by_date(datetime.first) # find or initialize by show day

      unless show.manual?
        if show.new_record? # if this is a new show
          show.time = datetime.last # set or update time

          # parsing something like this: <span class="location">Fillmore, The (SF), San Francisco CA</span>
          # let wrangling ensue!
          location = show.at('.location').inner_html.split(',')
          show.venue = location.first # note that anything after first space is ignored ie. "The (SF)" in above example
          location_chunks = location.last.strip.split(' ')

          # last chunk of array is either US state or foreign country
          region_or_country = location_chunks.pop
          if region_or_country.length == 2
            show.region = region_or_country
            show.country = "United States"
          else
            show.country = region_or_country
            show.region = region_or_country
          end

          # some final wranging to reassemble city name from array
          city = location_chunks.join(' ')
          show.city = city

          if show.at('.description') # if Sub Pop added a description
            show.notes = show.at('.description').inner_html
          end

        # else # just add description (if present) to existing record
          # if show.at('.description')
            # show.notes = show.at('.description').inner_html
          # end
        end
        show.save!
        @saved_shows << show.id if (show.new_record? && !@saved_shows.include?(show.id))
      end # end manual check
    end # end Sub Pop loop
    return subpop_shows
  end
end

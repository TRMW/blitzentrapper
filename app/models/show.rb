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
    saved_shows = []
    # grab shows from Bandsintown API
    bit_shows = JSON.parse(open('http://api.bandsintown.com/artists/Blitzen%20Trapper/events.json?app_id=blitzentrapper').read)

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
        show.save!
        saved_shows << show.id if (show.new_record? && !saved_shows.include?(show.id))
      end # end manual check

    end # end Bandsintown loop
    logger.info  "Grabbed #{bit_shows.length} shows from Bandsintown and created #{saved_shows.length} new shows."
  end

  def self.get_archive_starting_year
    Show.by_year(Date.today.beginning_of_year).first ? Date.today.year : Date.today.year - 1
  end
end

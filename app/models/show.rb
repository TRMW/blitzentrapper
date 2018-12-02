class Show < ActiveRecord::Base
  has_many :setlistings, -> { order :position }, :dependent => :destroy
  has_many :songs, -> { order 'setlistings.position' }, :through => :setlistings
  has_many :posts, -> { order :created_at }, :as => :postable, :dependent => :destroy
  validates_presence_of :city, :venue, :date
  after_create :create_setlists

  accepts_nested_attributes_for :setlistings, :allow_destroy => true
  accepts_nested_attributes_for :posts

  scope :today_forward, -> { where('(date >= ? OR enddate >= ?) AND visible = ? AND festival_dupe = ?', Date.today, Date.today, true, false).order(:date) }
  scope :by_year, -> (d) { where('(date >= ? AND date <= ? AND date <= ?) AND visible = ? AND festival_dupe = ?', d, d.end_of_year, Date.today, true, false).order(:date) }

  def create_setlists
    25.times do |i|
      self.setlistings.create
    end
  end

  def self.get_shows(date=nil)
    saved_shows = []
    # grab shows from Bandsintown API
    if date
      bit_shows = JSON.parse(open("https://rest.bandsintown.com/artists/Blitzen%20Trapper/events?app_id=blitzentrapper&date=#{date}").read)
    else
      bit_shows = JSON.parse(open('https://rest.bandsintown.com/artists/Blitzen%20Trapper/events?app_id=blitzentrapper').read)
    end

    bit_shows.each do |received_show|
      show = Show.find_or_initialize_by(bit_id: received_show['id'])

      unless show.manual?
        datetime = received_show['datetime'].split('T') #split datetime into date and time
        show.date = datetime.first # set or update time
        show.time = datetime.last # set or update time
        show.venue = received_show['venue']['name']
        ticket_offer = received_show['offers'].find { |offer| offer['type'] === 'Tickets' }
        if ticket_offer
          show.ticket_link = ticket_offer['url'] + '?affil_code=blitzentrapper'
          show.status = ticket_offer['status']
        end
        show.city = received_show['venue']['city']
        show.country = received_show['venue']['country']
        show.region = received_show['venue']['region']
        show.latitude = received_show['venue']['latitude']
        show.longitude = received_show['venue']['longitude']
        show.bit_id = received_show['id']
        saved_shows << show.id if (show.new_record? && !saved_shows.include?(show.id))
        show.save!
      end # end manual check

    end # end Bandsintown loop
    logger.info  "Grabbed #{bit_shows.length} shows from Bandsintown and created #{saved_shows.length} new shows."
    return  "Grabbed #{bit_shows.length} shows from Bandsintown and created #{saved_shows.length} new shows."
  end

  def self.get_archive_starting_year
    Show.by_year(Date.today.beginning_of_year).first ? Date.today.year : Date.today.year - 1
  end
end

class Show < ActiveRecord::Base
  has_many :setlistings, -> { order :position }, :dependent => :destroy
  has_many :songs, -> { order 'setlistings.position' }, :through => :setlistings
  has_many :posts, -> { order :created_at }, :as => :postable, :dependent => :destroy
  validates_presence_of :city, :venue, :date

  accepts_nested_attributes_for :setlistings, :allow_destroy => true
  accepts_nested_attributes_for :posts

  scope :today_forward, -> { where('(date >= ? OR enddate >= ?) AND visible = ? AND festival_dupe = ?', Date.today, Date.today, true, false).order(:date) }
  scope :by_year, -> (d) { where('(date >= ? AND date <= ? AND date <= ?) AND visible = ? AND festival_dupe = ?', d, d.end_of_year, Date.today, true, false).order(:date) }

  # Returns saved setlistings plus in-memory blank setlistings to fill up to 25 total
  # This provides a UI-friendly view with blank rows for users to fill in without
  # persisting empty rows to the database
  def setlistings_with_blanks
    saved = setlistings.order(:position).to_a
    blank_count = [0, 25 - saved.length].max

    blank_count.times do
      saved << Setlisting.new(show_id: id)
    end

    saved
  end

  # Override to_json to use setlistings_with_blanks by default
  def to_json(options = {})
    return super(options) unless should_use_blanks?(options)

    serialize_with_blank_setlistings(options)
  end

  private

  def should_use_blanks?(options)
    options[:include] && options[:include][:setlistings]
  end

  def serialize_with_blank_setlistings(options)
    options = options.dup
    options[:include] = options[:include].dup
    setlistings_config = options[:include].delete(:setlistings)

    attrs = attributes.dup
    attrs['setlistings'] = setlistings_with_blanks.map do |s|
      s.as_json(setlistings_config)
    end

    attrs.to_json
  end

  def self.get_shows(date = nil)
    saved_shows = []
    bit_shows = fetch_bandsintown_shows(date)
    process_bandsintown_shows(bit_shows, saved_shows)
    log_import_summary(bit_shows, saved_shows)
  end

  def self.archive_starting_year
    archive_year = by_year(Date.today.beginning_of_year).first
    archive_year ? Date.today.year : Date.today.year - 1
  end

  def self.fetch_bandsintown_shows(date)
    if date
      url = 'https://rest.bandsintown.com/artists/Blitzen%20Trapper/events?' \
            "app_id=blitzentrapper&date=#{date}"
    else
      url = 'https://rest.bandsintown.com/artists/Blitzen%20Trapper/events?' \
            'app_id=blitzentrapper'
    end

    JSON.parse(URI.open(url).read)
  end

  def self.process_bandsintown_shows(bit_shows, saved_shows)
    bit_shows.each do |received_show|
      show = find_or_initialize_by(bit_id: received_show['id'])

      next if show.manual?

      update_show_from_bandsintown(show, received_show)
      record_new_show(show, saved_shows)
      show.save!
    end
  end

  def self.record_new_show(show, saved_shows)
    return if !show.new_record? || saved_shows.include?(show.id)

    saved_shows << show.id
  end

  def self.update_show_from_bandsintown(show, received_show)
    datetime = received_show['datetime'].split('T')
    show.date = datetime.first
    show.time = datetime.last
    show.venue = received_show['venue']['name']

    update_ticket_link(show, received_show)
    update_location_info(show, received_show)
    update_bandsintown_id(show, received_show)
  end

  def self.update_ticket_link(show, received_show)
    ticket_offer = received_show['offers'].find do |offer|
      offer['type'] == 'Tickets'
    end

    return unless ticket_offer

    show.ticket_link = ticket_offer['url'] + '?affil_code=blitzentrapper'
    show.status = ticket_offer['status']
  end

  def self.update_location_info(show, received_show)
    show.city = received_show['venue']['city']
    show.country = received_show['venue']['country']
    show.region = received_show['venue']['region']
    show.latitude = received_show['venue']['latitude']
    show.longitude = received_show['venue']['longitude']
  end

  def self.update_bandsintown_id(show, received_show)
    show.bit_id = received_show['id']
  end

  def self.log_import_summary(bit_shows, saved_shows)
    message = "Grabbed #{bit_shows.length} shows from Bandsintown and " \
              "created #{saved_shows.length} new shows."
    logger.info message
    message
  end

  private_class_method :fetch_bandsintown_shows, :process_bandsintown_shows,
                       :record_new_show, :update_show_from_bandsintown,
                       :log_import_summary
end


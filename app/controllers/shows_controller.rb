class ShowsController < ApplicationController
  before_action :store_location, :only => :show
  before_action :require_admin, :only => [ :new, :edit, :destroy, :admin ]

  def index
    @shows_months = Show.today_forward.group_by { |show| show.date.beginning_of_month }
    expires_in 10.minutes, :public => true
    expires_now if params[:refresh]
  end

  def archive_index
    @year = Show.archive_starting_year
    get_year_variables
    render :archive
  end

  def admin
    @shows = Show.order(date: :desc)
  end

  def year
    @year = params[:year].to_i
    get_year_variables
    render :archive
  end

  def show
    @show = Show.find(params[:id])
    @user = User.new
  end

  def new
    @show = Show.new
  end

  def create
    @show = Show.new(show_params)
    if @show.save
      redirect_to @show, notice: 'Successfully created show.'
    else
      render :new
    end
  end

  def edit
    @show = Show.find(params[:id])
  end

  def update
    @show = Show.find(params[:id])

    # The setlist editor has `setlistings` and `songs` but we need to call
    # them `setlistings_attributes` and `song_attributes` for save to work
    if show_params.has_key? :setlistings
      setlistings_params = show_params.delete(:setlistings)
      setlistings_params.each do |setlisting_param|
        if setlisting_param.has_key? :song
          setlisting_param[:song_attributes] = setlisting_param.delete(:song)
        end
      end
      show_params[:setlistings_attributes] = build_setlistings_attributes(setlistings_params)
    end

    if @show.update_attributes(show_params)
      if request.xhr?
        render json: { status: :true }
      else
        redirect_to @show, notice: 'Successfully updated show.'
      end
    else
      if request.xhr?
        render :json => { :status => 422, :errors => @show.errors.full_messages }
      else
        render :show
      end
    end
  end

  def destroy
    @show = Show.find(params[:id])
    @show.destroy
    redirect_to shows_url(:refresh => true), notice: 'Successfully destroyed show.'
  end

  def refresh
    flash_string = Show.get_shows
    redirect_to shows_url(:refresh => true), notice: flash_string
  end

  def search
    query = params[:query].strip if params[:query]

    if query and request.xhr?
      # ILIKE for case-insensitive PostgreSQL search
      @shows = Show.where("city ILIKE ? OR venue ILIKE ?", "%#{query}%", "%#{query}%").order(date: :desc)
      render :partial => "search_results", :layout => false
    end
  end

  private

  # Splits the setlistings params sent from the React setlist editor into
  # the attributes that should actually be persisted:
  #
  # - Existing records (real database id) are always kept so they can be
  #   updated or destroyed as normal.
  # - Temporary records (temp_* id, built in-memory by
  #   Show#setlistings_with_blanks for the drag-and-drop UI) are only kept
  #   if the user actually filled them in with a song. The temp id is
  #   stripped so ActiveRecord treats them as new records to create.
  # - Untouched temporary blanks are discarded entirely.
  def build_setlistings_attributes(setlistings_params)
    setlistings_params.each_with_object([]) do |setlisting_param, result|
      id = setlisting_param[:id]

      if id.present? && !temp_setlisting_id?(id)
        result << setlisting_param
      elsif setlisting_filled_in?(setlisting_param)
        result << setlisting_param.except(:id)
      end
    end
  end

  def temp_setlisting_id?(id)
    id.to_s.start_with?('temp_')
  end

  def setlisting_filled_in?(setlisting_param)
    song_attributes = setlisting_param[:song_attributes]

    return true if song_attributes.present? && song_attributes[:title].present?

    setlisting_param[:song_id].present?
  end

  def show_params
    # TODO: Enumerate allowable params instead of relying on permit!
    params.require(:show).permit!
  end

  def get_year_variables
    @shows_months = Show.by_year(Date.new(@year)).group_by { |show| show.date.beginning_of_month }
    @years =  Show.archive_starting_year.downto(2007)
  end
end


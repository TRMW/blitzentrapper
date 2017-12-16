module ShowsHelper
  def show_state_or_country(show)
    if show.country == 'United States'
      show.region
    else
      show.country
    end
  end
end

module ShowsHelper
  def show_state_or_country(show)
    if show.country.blank? || show.country == 'United States'
      show.region
    else
      show.country
    end
  end

  def should_show_ticket_link?(show)
    show.status == "available" && (show.enddate? ? show.enddate : show.date) >= Date.today
  end
end

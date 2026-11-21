require "test_helper"

# The show page mounts the React setlist widget (app/javascript/setlist.jsx),
# which saves with a JSON PUT shaped like the ones below.
class ShowSetlistTest < ActionDispatch::IntegrationTest
  setup do
    @show = Show.create!(city: "Portland", venue: "Crystal Ballroom", date: Date.new(2024, 5, 4))
    @furr = Song.create!(title: "Furr")
  end

  test "past show page loads the setlist bundle and its data" do
    get show_path(@show)

    assert_response :success
    assert_select "script[src*='setlist'][defer]"
    data = JSON.parse(css_select("meta[name='blitzen-setlist-data-show']").first["content"])
    ids = data["setlistings"].map { |s| s["id"] }
    assert_equal 25, ids.uniq.size
    assert ids.all? { |id| id.start_with?("temp_") }, "blank slots need temp ids"
  end

  test "saving from the editor keeps filled slots and drops untouched blanks" do
    log_in_as("fan")
    save_setlist(encore: 1, setlistings: [
      { id: "temp_1", position: "1", song_id: @furr.id },
      { id: "temp_2", position: "2", song_id: nil, song: { title: "Brand New Song" } },
      { id: "temp_3", position: "3", song_id: nil }
    ])

    assert_equal "true", response.parsed_body["status"]
    @show.reload
    assert_equal [ "Furr", "Brand New Song" ], @show.setlistings.map { |s| s.song.title }
    assert_equal 1, @show.encore
  end

  test "visitors who aren't signed in can't change a setlist" do
    save_setlist(encore: 0, setlistings: [ { id: "temp_1", position: "1", song_id: @furr.id } ])

    assert_response :unauthorized
    assert_empty @show.reload.setlistings
  end

  test "signed-in fans can only change the setlist, not the show" do
    log_in_as("fan")
    save_setlist(venue: "Somewhere Else", encore: 0, setlistings: [])

    assert_equal "Crystal Ballroom", @show.reload.venue
  end

  test "admins can change the show" do
    log_in_as("Matt")
    put show_path(@show), params: { show: { venue: "Doug Fir" } }

    assert_redirected_to show_path(@show)
    assert_equal "Doug Fir", @show.reload.venue
  end

  test "only admins can create shows" do
    log_in_as("fan")
    assert_no_difference -> { Show.count } do
      post shows_path, params: { show: { city: "Portland", venue: "Doug Fir", date: "2024-06-01" } }
    end
    assert_redirected_to root_path
  end

  private

  def save_setlist(attrs)
    put show_path(@show), as: :json, xhr: true, params: { show: attrs }
  end

  def log_in_as(login)
    user = User.new(login: login, password: "secret123")
    user.reset_persistence_token
    user.save!(validate: false)
    post "/user_session", params: { user_session: { login: login, password: "secret123" } }
  end
end

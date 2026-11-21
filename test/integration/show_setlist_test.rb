require "test_helper"

# The show page mounts the React setlist widget (app/javascript/setlist.jsx),
# which saves with a JSON PUT shaped like the one below.
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
    put show_path(@show), as: :json, xhr: true, params: {
      show: {
        id: @show.id,
        encore: 1,
        setlistings: [
          { id: "temp_1", position: "1", song_id: @furr.id },
          { id: "temp_2", position: "2", song_id: nil, song: { title: "Brand New Song" } },
          { id: "temp_3", position: "3", song_id: nil }
        ]
      }
    }

    assert_equal "true", response.parsed_body["status"]
    @show.reload
    assert_equal [ "Furr", "Brand New Song" ], @show.setlistings.map { |s| s.song.title }
    assert_equal 1, @show.encore
  end
end

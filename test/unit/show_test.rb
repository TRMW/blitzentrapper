require 'test_helper'

class ShowTest < ActiveSupport::TestCase
  test "not valid without region" do
    show = Show.new
    assert !show.save, "Saved the show without any fields"
  end
  
  test "show saves with required fields entered" do
  	show = Show.new(:city => "Auburn",
  									:region => "CA",
  									:venue => "Awful Annie's",
  									:date => 2010-05-19
  									)
  	assert show.save, "Show didn't save despite all required fields being entered"
  end
  
  test "successful show save creates 25 new setlistings, etc" do
  	show = Show.new(:city => "Auburn",
								:region => "CA",
								:venue => "Awful Annie's",
								:date => 2010-05-19
								)
		assert show.save
		assert_equal 25, show.setlistings.length, "Less than 25 setlistings for show"
		assert_equal 20, show.encore, "Show encore didn't default to 20"
		assert_nil show.setlistings.first.song_id, "First setlisting contains a song_id"
	end
end

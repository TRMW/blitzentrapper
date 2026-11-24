require "test_helper"

class ForumSearchTest < ActionDispatch::IntegrationTest
  # The forum page puts /forum/search in the search box's data-action, so
  # crawlers request it with GET. It used to fall through to topics#show and
  # raise RecordNotFound for a topic called "search".
  test "GET /forum/search without a query redirects to the forum" do
    get "/forum/search"

    assert_redirected_to topics_url
  end

  test "GET /forum/search/:query shows results" do
    get "/forum/search/furr"

    assert_response :success
  end
end

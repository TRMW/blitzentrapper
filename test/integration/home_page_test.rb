require 'test_helper'

class HomePageTest < ActionDispatch::IntegrationTest
  test "can see the home page" do
    get "/"
    assert_select ".header__logo"
  end
end

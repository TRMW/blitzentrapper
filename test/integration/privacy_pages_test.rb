require 'test_helper'

class PrivacyPagesTest < ActionDispatch::IntegrationTest
  test 'shows the privacy policy' do
    get '/privacy'
    assert_response :success
    assert_select 'h1', 'Privacy Policy'
    assert_select "a[href='mailto:#{HomeHelper::PRIVACY_EMAIL}']"
  end

  test 'shows how to delete your data' do
    get '/data-deletion'
    assert_response :success
    assert_select 'h1', 'Delete Your Data'
    assert_select "a[href^='mailto:#{HomeHelper::PRIVACY_EMAIL}']"
  end
end

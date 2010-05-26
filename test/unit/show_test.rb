require 'test_helper'

class ShowTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Show.new.valid?
  end
end

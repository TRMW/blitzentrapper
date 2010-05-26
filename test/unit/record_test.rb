require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Record.new.valid?
  end
end

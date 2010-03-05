require 'test_helper'

class TableTest < ActiveSupport::TestCase
  setup do
    @table = Factory.build(:table)
  end

  test "is valid with valid attributes" do
    assert @table.valid?
  end
end

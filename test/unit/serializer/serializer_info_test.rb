require "test_helper"
require "table_factories_helper"

class SerializerInfoTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when no board present" do
    table = table_without_board
    expected = {:tableId => table.id, :dealer => "", :vulnerable => "", :visible => true}
    assert_equal expected, Serializer.new(table).info
  end

  test "return board values when board is present" do
    table = table_before_first_lead
    board = table.boards.current
    expected = {:tableId => table.id, :dealer => board.dealer, :vulnerable => board.vulnerable, :visible => true}
    assert_equal expected, Serializer.new(table).info
  end
end

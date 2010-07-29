require "test_helper"
require "table_factories_helper"

class SerializerClaimTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not playing" do
    table = table_without_board
    expected = {:maxTricks => 13, :visible => false}
    assert_equal expected, Serializer.new(table).claim(Factory(:user))
  end

  test "should set visible to true for playing user" do
    table = table_before_first_lead
    board = table.boards.current
    expected = {:maxTricks => 13, :visible => true}
    assert_equal expected, Serializer.new(table).claim(board.user_e)
  end

  test "should not set visible when user is not playing" do
    table = table_before_first_lead
    board = table.boards.current
    expected = {:maxTricks => 13, :visible => false}
    assert_equal expected, Serializer.new(table).claim(board.user_n)
  end

  test "should not set visible when there is claim already" do
    table = table_before_first_lead
    board = table.boards.current
    Factory(:claim, :board => board)
    expected = {:maxTricks => 13, :visible => false}
    assert_equal expected, Serializer.new(table).claim(board.user_e)
  end
end

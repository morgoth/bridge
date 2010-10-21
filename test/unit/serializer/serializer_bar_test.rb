require "test_helper"
require "table_factories_helper"

class SerializerBarTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values for guest" do
    table = table_without_board
    expected = {:visible => true, :quitEnabled => false, :claimEnabled => false}
    assert_equal expected, Serializer.new(table).bar(Factory(:user))
  end

  # claimEnabled tests
  test "should set claim enabled to true for playing user" do
    table = table_before_first_lead
    board = table.boards.current
    assert_true Serializer.new(table).bar(board.user_e)[:claimEnabled]
  end

  test "should not set claim enabled when user is not playing" do
    table = table_before_first_lead
    board = table.boards.current
    assert_false Serializer.new(table).bar(board.user_n)[:claimEnabled]
  end

  test "should not set claim enabled when there is claim already" do
    table = table_before_first_lead
    board = table.boards.current
    Factory(:claim, :board => board)
    assert_false Serializer.new(table).bar(board.user_e)[:claimEnabled]
  end
end

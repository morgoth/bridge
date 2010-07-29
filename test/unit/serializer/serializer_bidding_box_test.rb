require "test_helper"
require "table_factories_helper"

class SerializerBiddingBoxTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not in auction state" do
    table = table_without_board
    expected = {:contract => "", :disabled => true, :visible => false, :doubleEnabled => false, :redoubleEnabled => false}
    assert_equal expected, Serializer.new(table).bidding_box(Factory(:user))
  end

  test "should return current contract when in auction state" do
    table = table_with_auction
    expected_contract = "2H"
    assert_equal expected_contract, Serializer.new(table).bidding_box(Factory(:user))[:contract]
  end

  test "should set attributes for playing user" do
    table = table_with_auction
    board = table.boards.current
    expected = {:contract => "2H", :disabled => false, :visible => true, :doubleEnabled => true, :redoubleEnabled => false}
    assert_equal expected, Serializer.new(table).bidding_box(board.current_user)
  end

  test "should not set attributes when user cannot play" do
    table = table_with_auction
    board = table.boards.current
    expected = {:contract => "2H", :disabled => true, :visible => false, :doubleEnabled => false, :redoubleEnabled => false}
    assert_equal expected, Serializer.new(table).bidding_box(board.current_user.previous)
  end
end

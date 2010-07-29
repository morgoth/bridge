require "test_helper"
require "table_factories_helper"

class SerializerAuctionTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values without board" do
    table = table_without_board
    expected = {:names => [], :dealer => "", :vulnerable => "", :visible => true, :bids => []}
    assert_equal expected, Serializer.new(table).auction(table.players.first.user)
  end

  test "should return full board auction for guest" do
    table = table_with_auction
    board = table.boards.current
    bids = [{:bid => "PASS", :alert => nil}, {:bid => "2H", :alert => "Multi"}]
    expected = {:names => board.users.map(&:name), :dealer => board.dealer, :vulnerable => board.vulnerable, :visible => true, :bids => bids}
    assert_equal expected, Serializer.new(table).auction(Factory(:user))
  end

  test "should return bids without alert for partner of alerting user" do
    table = table_with_auction
    board = table.boards.current
    partner = board.bids.where(:bid => "2H").first.user.partner
    expected_bids = [{:bid => "PASS", :alert => nil}, {:bid => "2H", :alert => nil}]
    assert_equal expected_bids, Serializer.new(table).auction(partner)[:bids]
  end
end

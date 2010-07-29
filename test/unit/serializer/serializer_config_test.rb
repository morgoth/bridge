require "test_helper"
require "table_factories_helper"

class SerializerConfigTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  # TODO: change to config tests only
  def setup
    @table = table_before_first_lead
    @board = @table.boards.current
    @serializer = Serializer.new(@table)
  end

  test "should set current board" do
    assert_equal @board, @serializer.board
  end

  test "should return info" do
    expected = {:tableId => @table.id, :vulnerable => @board.vulnerable, :dealer => @board.dealer, :visible => true}
    assert_equal expected, @serializer.info
  end

  test "should return auction" do
    expected = {:names => @table.players.map(&:name),
      :dealer => @board.dealer,
      :vulnerable => @board.vulnerable,
      :visible => true,
      :bids => [{:bid => "1S", :alert => nil},
                {:bid => "PASS", :alert => nil},
                {:bid => "PASS", :alert => nil},
                {:bid => "PASS", :alert => nil}]
    }
    assert_equal expected, @serializer.auction(@board.user_n)
  end
end

require "test_helper"
require "table_factories_helper"

class SerializerTricksTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not playing" do
    table = table_without_board
    expected = {:contract => "", :declarer => "", :resultNS => 0, :resultEW => 0, :tricks => [], :visible => false}
    assert_equal expected, Serializer.new(table).tricks
  end

  test "should set board attributes when playing" do
    table = table_before_first_lead
    board = table.boards.current
    expected = {:contract => "1S", :declarer => "N", :resultNS => 0, :resultEW => 0, :tricks => [], :visible => true}
    assert_equal expected, Serializer.new(table).tricks
  end

  test "should map completed tricks" do
    table = table_with_trick
    tricks = [{:cards =>["HA", "D2", "C2", "S2"], :lead => "E", :winner => "N"}]
    expected = {:contract => "1S", :declarer => "N", :resultNS => 1, :resultEW => 0, :tricks => tricks, :visible => true}
    assert_equal expected, Serializer.new(table).tricks
  end
end

require "test_helper"
require "table_factories_helper"

class SerializerTrickTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not playing" do
    table = table_without_board
    expected = {:lead => nil, :cards => nil, :visible => false}
    assert_equal expected, Serializer.new(table).trick
  end

  test "should set visible to true when playing" do
    table = table_before_first_lead
    expected = {:lead => nil, :cards => nil, :visible => true}
    assert_equal expected, Serializer.new(table).trick
  end

  test "should set current trick when present" do
    table = table_before_first_lead
    board = table.boards.current
    board.cards.create!(:card => "HA", :user => board.user_e)
    expected = {:lead => "E", :cards => ["HA"], :visible => true}
    assert_equal expected, Serializer.new(table).trick
  end

  test "should set previous trick when no current present" do
    table = table_with_trick
    expected = {:lead => "E", :cards => ["HA", "D2", "C2", "S2"], :visible => true}
    assert_equal expected, Serializer.new(table).trick
  end
end

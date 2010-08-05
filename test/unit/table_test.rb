require "test_helper"

class TableTest < ActiveSupport::TestCase
  setup do
    @table = Factory.build(:table)
  end

  test "is valid with valid attributes" do
    assert @table.valid?
  end

  test "starts if four players on table" do
    @table.save!
    Factory(:player, :table => @table, :direction => "N")
    assert @table.reload.preparing?
    Factory(:player, :table => @table, :direction => "E")
    assert @table.reload.preparing?
    Factory(:player, :table => @table, :direction => "S")
    assert @table.reload.preparing?
    Factory(:player, :table => @table, :direction => "W")
    assert @table.reload.playing?
  end

  test "creates a new board after start" do
    @table.save!
    assert_nil @table.reload.boards.current
    %w(N E S W).each { |direction| Factory(:player, :table => @table, :direction => direction) }
    assert @table.reload.boards.current
  end

  test "touch increases version number by one" do
    @table.save!
    assert_difference("@table.version") { @table.touch }
  end

  test "save increases version number by one" do
    @table.save!
    assert_difference("@table.version") { @table.save! }
  end
end

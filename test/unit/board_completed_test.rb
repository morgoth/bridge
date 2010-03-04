require "test_helper"

class BoardCompletedTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:full_board)
    # 1S-N +2
  end

  test "is in the completed state" do
    assert @board.completed?
  end

  test "return tricks" do
    trick_1 = @board.cards.all(:limit => 4)
    trick_2 = @board.cards.where(:position => 5...9).all
    assert_equal trick_1, @board.cards.tricks.first
    assert_equal trick_2, @board.cards.tricks[1]
    assert_equal 13, @board.cards.tricks.size
  end

  test "return trick" do
    trick_1 = @board.cards.all(:limit => 4)
    trick_2 = @board.cards.where(:position => 5...9).all
    trick_13 = @board.cards.where(:position => 49...53).all
    assert_equal trick_1, @board.cards.trick(1)
    assert_equal trick_2, @board.cards.trick(2)
    assert_equal trick_13, @board.cards.trick(13)
  end

  test "return tricks taken by ns" do
    assert_equal 9, @board.tricks_taken("ns")
  end

  test "return tricks taken by ew" do
    assert_equal 4, @board.tricks_taken("ew")
  end

  test "return true for made contract" do
    assert @board.score_made?
  end

  test "return 2 as score result" do
    assert_equal 2, @board.score_result
  end

  test "return 140 as score points" do
    assert_equal 140, @board.score_points
  end
end

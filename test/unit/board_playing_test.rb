require "test_helper"

class BoardPlayingTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N)
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  test "board is in the playing state after auction" do
    assert @board.playing?
  end

  test "cards_left should return all cards" do
    assert_equal @board.deal, @board.cards_left
  end

  test "cards_left should return cards without HA" do
    cards = @board.deal
    cards[:e].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards, @board.cards_left
  end

  test "cards_left should return E cards without HA" do
    cards = @board.deal
    cards[:e].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards[:e], @board.cards_left(:e)
  end

  test "completed tricks count returns 0" do
    assert_equal 0, @board.cards.completed_tricks_count
  end

  test "accepted claim changes board state to completed" do
    Factory(:accepted_claim, :board => @board, :user => @user_n)
    assert @board.completed?
  end
end

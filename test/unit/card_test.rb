require "test_helper"

class CardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N)
  end

  test "return suit of card" do
    card = @board.cards.build(:card => "SA")
    assert_equal "S", card.suit
  end

  test "return true if cards in same suit" do
    card = Factory.build(:card, :card => "SA")
    other = Factory.build(:card, :card => "SQ")
    assert_equal card.suit, other.suit
  end

  test "return false if cards not in same suit" do
    card = Factory.build(:card, :card => "SA")
    other = Factory.build(:card, :card => "DQ")
    assert_not_equal card.suit, other.suit
  end

  test "return deal of board" do
    card = Factory.build(:card, :board => @board)
    assert_equal @board.deal, card.board_deal
  end

  test "lead? should return true if first card" do
    card = Factory.build(:card)
    assert card.current_lead?
  end

  test "lead? should return true if fifth card" do
    card = Factory.build(:card, :position => 5)
    assert card.current_lead?
  end
end

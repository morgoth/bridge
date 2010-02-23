require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board)
  end

  test "return suit of card" do
    card = Factory.build(:card, :value => "SA")
    assert_equal :s, card.suit
  end

  test "return true if cards in same suit" do
    card = Factory.build(:card, :value => "SA")
    other = Factory.build(:card, :value => "SQ")
    assert card.in_same_suit?(other)
  end

  test "return false if cards not in same suit" do
    card = Factory.build(:card, :value => "SA")
    other = Factory.build(:card, :value => "DQ")
    assert_false card.in_same_suit?(other)
  end

  test "return deck of board" do
    card = Factory.build(:card, :board => @board)
    assert_equal @board.deck, card.board_deck
  end

  test "lead? should return true if first card" do
    card = Factory.build(:card)
    assert card.send(:lead?)
  end

  test "lead? should return true if fifth card" do

  end
end

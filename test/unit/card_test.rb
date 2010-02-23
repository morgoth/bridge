require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board)
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

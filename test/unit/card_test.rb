require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1N_by_S)
  end

  test "return suit of card" do
    card = Factory.build(:card, :value => "SA")
    assert_equal "S", card.suit
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

  test "return deal of board" do
    card = Factory.build(:card, :board => @board)
    assert_equal @board.deal, card.board_deal
  end

  test "lead? should return true if first card" do
    card = Factory.build(:card)
    assert card.send(:lead?)
  end

  test "lead? should return true if fifth card" do
    card = Factory.build(:card, :position => 5)
    assert card.send(:lead?)
  end
end

class CardValidationTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1N_by_S)
    @card = Factory.build(:card, :board => @board)
  end

  test "not valid with wrong value" do
    @card.value = "G2"
    assert @card.invalid?
    assert @card.errors[:value].present?
  end

  test "valid when card is in hand of first lead user" do
    # E is first lead user
    hand = @board.e_hand
    @card.value = hand.first
    assert @card.valid?
  end

  test "not valid when card is not in hand of first lead user" do
    # E is first lead user
    hand = @board.w_hand
    @card.value = hand.first
    assert @card.invalid?
    assert @card.errors[:value].present?
  end
end
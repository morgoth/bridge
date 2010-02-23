require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N)
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
    @board = Factory(:board_1S_by_N)
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

  test "not valid when card is in other suit than last card and suit is present on hand" do
    board = Factory(:board_1S_by_N, :deal_id => 636839108127179982824423290.to_s )
    # :n => ["SA", "SK", "SQ", "S8", "S6", "HK", "H7", "H6", "H4", "DK", "DQ", "DJ", "C3"]
    # :e => ["S5", "S4", "S3", "HA", "HQ", "HJ", "H9", "D5", "D4", "CK", "CJ", "C9", "C5"]
    # :s => ["ST", "S7", "S2", "HT", "H8", "H2", "DT", "D8", "D3", "CA", "CT", "C6", "C2"]
    # :w => ["SJ", "S9", "H5", "H3", "DA", "D9", "D7", "D6", "D2", "CQ", "C8", "C7", "C4"]
    # E is first lead user
    board.cards.create!(:value => "S5")
    card = board.cards.build(:value => "HT")
    assert card.invalid?
    assert card.errors[:value].present?
  end
end
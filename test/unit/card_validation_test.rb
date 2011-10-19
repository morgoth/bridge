require "test_helper"

class CardValidationTest < ActiveSupport::TestCase
  setup do
    @board = FactoryGirl.create(:board_1s_by_n)
    @card = FactoryGirl.build(:card, :board => @board, :user => @board.user_n)
  end

  test "not valid with wrong card" do
    @card.card = "G2"
    assert @card.invalid?
    assert @card.errors[:card].present?
  end

  test "valid when card is in hand of first lead user" do
    # E is first lead user
    hand = @board.deal_e
    @card.card = hand.first.to_s
    @card.user = @board.user_e
    assert @card.valid?
  end

  test "not valid when card is not in hand of first lead user" do
    # E is first lead user
    hand = @board.deal_w
    @card.card = hand.first
    @card.user = @board.user_e
    assert @card.invalid?
    assert @card.errors[:card].present?
  end

  test "not valid when user is not the next one" do
    @board.cards.create!(:card => "HA", :user => @board.user_e)
    card = @board.cards.build(:card => "C2", :user => @board.user_w)
    assert card.invalid?
    assert card.errors[:user].present?
  end

  test "not valid when the current_user is dummy and user is dummy" do
    @board.cards.create!(:card => "HA", :user => @board.user_e)
    card = @board.cards.build(:card => "DA", :user => @board.user_s)
    assert card.invalid?
    assert card.errors[:user].present?
  end

  test "not valid when the current_user is dummy and user is W opponent" do
    @board.cards.create!(:card => "HA", :user => @board.user_e)
    card = @board.cards.build(:card => "DA", :user => @board.user_w)
    assert card.invalid?
    assert card.errors[:user].present?
  end

  test "not valid when the current_user is dummy and user is E opponent" do
    @board.cards.create!(:card => "HA", :user => @board.user_e)
    card = @board.cards.build(:card => "DA", :user => @board.user_e)
    assert card.invalid?
    assert card.errors[:user].present?
  end

  test "not valid when card is in other suit than last card and suit is present on hand" do
    board = FactoryGirl.create(:board_1s_by_n, :deal_id => 636839108127179982824423290.to_s)
    # :n => ["SA", "SK", "SQ", "S8", "S6", "HK", "H7", "H6", "H4", "DK", "DQ", "DJ", "C3"]
    # :e => ["S5", "S4", "S3", "HA", "HQ", "HJ", "H9", "D5", "D4", "CK", "CJ", "C9", "C5"]
    # :s => ["ST", "S7", "S2", "HT", "H8", "H2", "DT", "D8", "D3", "CA", "CT", "C6", "C2"]
    # :w => ["SJ", "S9", "H5", "H3", "DA", "D9", "D7", "D6", "D2", "CQ", "C8", "C7", "C4"]
    # E is first lead user
    board.cards.create!(:card => "S5", :user => board.user_e)
    card = board.cards.build(:card => "HT", :user => board.user_s)
    assert card.invalid?
    assert card.errors[:card].present?
  end
end

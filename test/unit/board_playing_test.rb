require "test_helper"

class BoardPlayingTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N)
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  test "return user N as declarer" do
    assert_equal @user_n, @board.declarer_user
  end

  test "return user E as first lead user" do
    assert_equal @user_e, @board.first_lead_user
  end

  test "return user S as dummy user" do
    assert_equal @user_s, @board.dummy_user
  end

  test "board is in the playing state after auction" do
    assert @board.playing?
  end

  test "cards_left should return all cards" do
    assert_equal @board.deal.to_hash, @board.cards_left
  end

  test "cards_left should return cards without HA" do
    cards = @board.deal.to_hash
    cards["E"].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards, @board.cards_left
  end

  test "cards_left should return E cards without HA" do
    cards = @board.deal.to_hash
    cards["E"].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards["E"], @board.cards_left("E")
  end

  test "completed tricks count returns 0" do
    assert_equal 0, @board.cards.completed_tricks_count
  end

  test "accepted claim changes board state to completed" do
    Factory(:accepted_claim, :board => @board, :user => @user_n)
    assert @board.completed?
  end

  test "playing a card rejects active claims" do
    claim = Factory(:claim, :board => @board, :user => @user_n)
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert claim.reload.rejected?
  end

  test "claiming rejects active claims" do
    claim1 = Factory(:claim, :board => @board, :user => @user_n)
    claim2 = Factory(:claim, :board => @board, :user => @user_n)
    assert claim1.reload.rejected?
    assert claim2.reload.proposed?
  end

  test "set tricks to ns after claim" do
    claim = Factory(:accepted_claim, :board => @board, :tricks => 9)
    assert_equal 9, claim.board.tricks_ns
    assert_equal 4, claim.board.tricks_ew
  end

  test "return visible hands for N if no card played" do
    hands = @board.send(:hands_for, @user_n)
    assert_equal @board.cards_left("N"), hands["N"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["E"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["S"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["W"]
  end

  test "return visible hands for N if card played (self and dummy)" do
    @board.cards.create!(:card => "HA", :user => @user_e)
    hands = @board.send(:hands_for, @user_n)
    assert_equal @board.cards_left("N"), hands["N"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", ""], hands["E"]
    assert_equal @board.cards_left("S"), hands["S"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["W"]
  end

  test "return visible hands for N if claimed (self, dummy and claiming user)" do
    @board.cards.create!(:card => "HA", :user => @user_e)
    Factory(:claim, :board => @board, :user => @user_e)
    hands = @board.send(:hands_for, @user_n)
    assert_equal @board.cards_left("N"), hands["N"]
    assert_equal @board.cards_left("E"), hands["E"]
    assert_equal @board.cards_left("S"), hands["S"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["W"]
  end

  test "return empty strings if player is nil" do
    hands = @board.send(:hands_for, nil)
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["N"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["E"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["S"]
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", "", ""], hands["W"]
  end
end

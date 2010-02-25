require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  def setup
    @board = Factory(:board)
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  test "deal_<direction> methods should return cards" do
    assert_equal @board.deal[:n], @board.deal_n
    assert_equal @board.deal[:e], @board.deal_e
    assert_equal @board.deal[:s], @board.deal_s
    assert_equal @board.deal[:w], @board.deal_w
  end

  test "return E as first lead user when plays N" do
    @board.dealer = "N"
    @board.save!
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal @user_e, @board.first_lead_user
  end

  test "return S as first lead user when plays E" do
    @board.dealer = "N"
    @board.save!
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "1S", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal @user_s, @board.first_lead_user
  end

  test "cards_left should return all cards" do
    board = Factory(:board_1S_by_N)
    assert_equal board.deal, board.cards_left
  end

  test "cards_left should return cards without HA" do
    board = Factory(:board_1S_by_N)
    cards = board.deal
    cards[:e].delete("HA")
    board.cards.create!(:card => "HA", :user => board.user_e)
    assert_equal cards, board.cards_left
  end

  test "cards_left should return E cards without HA" do
    board = Factory(:board_1S_by_N)
    cards = board.deal
    cards[:e].delete("HA")
    board.cards.create!(:card => "HA", :user => board.user_e)
    assert_equal cards[:e], board.cards_left(:e)
  end
end

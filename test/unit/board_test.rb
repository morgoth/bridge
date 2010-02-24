require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  def setup
    @board = Factory(:board)
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  test "hands methods should return cards" do
    assert_equal @board.deal[:n], @board.n_hand
    assert_equal @board.deal[:e], @board.e_hand
    assert_equal @board.deal[:s], @board.s_hand
    assert_equal @board.deal[:w], @board.w_hand
  end

  test "nth bid user returns correct users when dealer is N" do
    @board.dealer = "N"
    assert_equal @user_n, @board.bids.user(1)
    assert_equal @user_e, @board.bids.user(2)
    assert_equal @user_s, @board.bids.user(3)
    assert_equal @user_w, @board.bids.user(4)
    assert_equal @user_n, @board.bids.user(5)
    assert_equal @user_e, @board.bids.user(6)
    assert_equal @user_s, @board.bids.user(7)
    assert_equal @user_w, @board.bids.user(8)
  end

  test "nth bid user returns correct users when dealer is E" do
    @board.dealer = "E"
    assert_equal @user_e, @board.bids.user(1)
    assert_equal @user_s, @board.bids.user(2)
    assert_equal @user_w, @board.bids.user(3)
    assert_equal @user_n, @board.bids.user(4)
    assert_equal @user_e, @board.bids.user(5)
    assert_equal @user_s, @board.bids.user(6)
    assert_equal @user_w, @board.bids.user(7)
    assert_equal @user_n, @board.bids.user(8)
  end

  test "nth bid user returns correct users when dealer is S" do
    @board.dealer = "S"
    assert_equal @user_s, @board.bids.user(1)
    assert_equal @user_w, @board.bids.user(2)
    assert_equal @user_n, @board.bids.user(3)
    assert_equal @user_e, @board.bids.user(4)
    assert_equal @user_s, @board.bids.user(5)
    assert_equal @user_w, @board.bids.user(6)
    assert_equal @user_n, @board.bids.user(7)
    assert_equal @user_e, @board.bids.user(8)
  end

  test "nth bid user returns correct users when dealer is W" do
    @board.dealer = "W"
    assert_equal @user_w, @board.bids.user(1)
    assert_equal @user_n, @board.bids.user(2)
    assert_equal @user_e, @board.bids.user(3)
    assert_equal @user_s, @board.bids.user(4)
    assert_equal @user_w, @board.bids.user(5)
    assert_equal @user_n, @board.bids.user(6)
    assert_equal @user_e, @board.bids.user(7)
    assert_equal @user_s, @board.bids.user(8)
  end

  test "return E as first lead user when plays N" do
    @board.dealer = "N"
    @board.save!
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)
    assert_equal @user_e, @board.first_lead_user
  end

  test "return S as first lead user when plays E" do
    @board.dealer = "N"
    @board.save!
    @board.bids.create!(:value => "PASS", :user => @user_n)
    @board.bids.create!(:value => "1S", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)
    @board.bids.create!(:value => "PASS", :user => @user_n)
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
    board.cards.create!(:value => "HA")
    assert_equal cards, board.cards_left
  end

  test "cards_left should return E cards without HA" do
    board = Factory(:board_1S_by_N)
    cards = board.deal
    cards[:e].delete("HA")
    board.cards.create!(:value => "HA")
    assert_equal cards[:e], board.cards_left(:e)
  end
end

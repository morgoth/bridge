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
    assert_equal board.deck[:n], board.n_hand
    assert_equal board.deck[:e], board.e_hand
    assert_equal board.deck[:s], board.s_hand
    assert_equal board.deck[:w], board.w_hand
  end

  test "nth bid user returns correct users when dealer is N" do
    @board.dealer = "N"
    assert_equal @user_n, @board.nth_bid_user(1)
    assert_equal @user_e, @board.nth_bid_user(2)
    assert_equal @user_s, @board.nth_bid_user(3)
    assert_equal @user_w, @board.nth_bid_user(4)
    assert_equal @user_n, @board.nth_bid_user(5)
    assert_equal @user_e, @board.nth_bid_user(6)
    assert_equal @user_s, @board.nth_bid_user(7)
    assert_equal @user_w, @board.nth_bid_user(8)
  end

  test "nth bid user returns correct users when dealer is E" do
    @board.dealer = "E"
    assert_equal @user_e, @board.nth_bid_user(1)
    assert_equal @user_s, @board.nth_bid_user(2)
    assert_equal @user_w, @board.nth_bid_user(3)
    assert_equal @user_n, @board.nth_bid_user(4)
    assert_equal @user_e, @board.nth_bid_user(5)
    assert_equal @user_s, @board.nth_bid_user(6)
    assert_equal @user_w, @board.nth_bid_user(7)
    assert_equal @user_n, @board.nth_bid_user(8)
  end

  test "nth bid user returns correct users when dealer is S" do
    @board.dealer = "S"
    assert_equal @user_s, @board.nth_bid_user(1)
    assert_equal @user_w, @board.nth_bid_user(2)
    assert_equal @user_n, @board.nth_bid_user(3)
    assert_equal @user_e, @board.nth_bid_user(4)
    assert_equal @user_s, @board.nth_bid_user(5)
    assert_equal @user_w, @board.nth_bid_user(6)
    assert_equal @user_n, @board.nth_bid_user(7)
    assert_equal @user_e, @board.nth_bid_user(8)
  end

  test "nth bid user returns correct users when dealer is W" do
    @board.dealer = "W"
    assert_equal @user_w, @board.nth_bid_user(1)
    assert_equal @user_n, @board.nth_bid_user(2)
    assert_equal @user_e, @board.nth_bid_user(3)
    assert_equal @user_s, @board.nth_bid_user(4)
    assert_equal @user_w, @board.nth_bid_user(5)
    assert_equal @user_n, @board.nth_bid_user(6)
    assert_equal @user_e, @board.nth_bid_user(7)
    assert_equal @user_s, @board.nth_bid_user(8)
  end
end

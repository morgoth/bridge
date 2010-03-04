require "test_helper"

class BoardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board, :dealer => "N")
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
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal @user_e, @board.reload.first_lead_user
  end

  test "return S as first lead user when plays E" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "1S", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal @user_s, @board.reload.first_lead_user
  end

  test "is in the completed state after four passes auction" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert @board.reload.completed?
  end

  test "return contract string without modifier" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal "5S", @board.reload.contract_without_modifier.to_s
  end

  test "return contract suit" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal "S", @board.reload.contract_suit
  end

  test "return contract trump" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal "S", @board.reload.contract_trump
  end
end

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
    assert_equal @user_e, @board.first_lead_user
  end

  test "return S as first lead user when plays E" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "1S", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal @user_s, @board.first_lead_user
  end

  test "is in the completed state after four passes auction" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert @board.reload.completed?
  end

  test "return contract string without modifiers" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal "5S", @board.final_contract_string
  end

  test "return contract string with double modifier" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal "5SX", @board.final_contract_string
  end

  test "return contract string with redouble modifier" do
    @board.bids.create!(:bid => "5S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    assert_equal "5SXX", @board.final_contract_string
  end
end

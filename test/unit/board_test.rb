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

class PlayingBoardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N)
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  test "board is in the playing state after auction" do
    assert @board.playing?
  end

  test "cards_left should return all cards" do
    assert_equal @board.deal, @board.cards_left
  end

  test "cards_left should return cards without HA" do
    cards = @board.deal
    cards[:e].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards, @board.cards_left
  end

  test "cards_left should return E cards without HA" do
    cards = @board.deal
    cards[:e].delete("HA")
    @board.cards.create!(:card => "HA", :user => @user_e)
    assert_equal cards[:e], @board.cards_left(:e)
  end

  test "completed tricks count returns 0" do
    assert_equal 0, @board.cards.completed_tricks_count
  end
end

class CompletedBoardTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:full_board)
  end

  test "is in the completed state" do
    assert @board.completed?
  end

  test "return tricks" do
    trick_1 = @board.cards.all(:limit => 4)
    trick_2 = @board.cards.where(:position => 5...9).all
    assert_equal trick_1, @board.cards.tricks.first
    assert_equal trick_2, @board.cards.tricks[1]
    assert_equal 13, @board.cards.tricks.size
  end

  test "return trick" do
    trick_1 = @board.cards.all(:limit => 4)
    trick_2 = @board.cards.where(:position => 5...9).all
    trick_13 = @board.cards.where(:position => 49...53).all
    assert_equal trick_1, @board.cards.trick(1)
    assert_equal trick_2, @board.cards.trick(2)
    assert_equal trick_13, @board.cards.trick(13)
  end

  test "return tricks taken by ns" do
    assert_equal 9, @board.tricks_taken("ns")
  end

  test "return tricks taken by ew" do
    assert_equal 4, @board.tricks_taken("ew")
  end
end

require "test_helper"

class CardPlayingTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N, :deal_id => 636839108127179982824423290.to_s )
    # :n => ["SA", "SK", "SQ", "S8", "S6", "HK", "H7", "H6", "H4", "DK", "DQ", "DJ", "C3"]
    # :e => ["S5", "S4", "S3", "HA", "HQ", "HJ", "H9", "D5", "D4", "CK", "CJ", "C9", "C5"]
    # :s => ["ST", "S7", "S2", "HT", "H8", "H2", "DT", "D8", "D3", "CA", "CT", "C6", "C2"]
    # :w => ["SJ", "S9", "H5", "H3", "DA", "D9", "D7", "D6", "D2", "CQ", "C8", "C7", "C4"]
    # E is first lead user
  end

  test "play whole deal" do
    @board.cards.create!(:card => "S5", :user => @board.user_e)
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    @board.cards.create!(:card => "SA", :user => @board.user_n)

    @board.cards.create!(:card => "SK", :user => @board.user_n)
    @board.cards.create!(:card => "S3", :user => @board.user_e)
    @board.cards.create!(:card => "S2", :user => @board.user_n)
    @board.cards.create!(:card => "S9", :user => @board.user_w)

    @board.cards.create!(:card => "SQ", :user => @board.user_n)
    @board.cards.create!(:card => "S4", :user => @board.user_e)
    @board.cards.create!(:card => "S7", :user => @board.user_n)
    @board.cards.create!(:card => "D2", :user => @board.user_w)

    @board.cards.create!(:card => "DK", :user => @board.user_n)
    @board.cards.create!(:card => "D4", :user => @board.user_e)
    @board.cards.create!(:card => "D3", :user => @board.user_n)
    @board.cards.create!(:card => "D9", :user => @board.user_w)

    @board.cards.create!(:card => "C3", :user => @board.user_n)
    @board.cards.create!(:card => "CK", :user => @board.user_e)
    @board.cards.create!(:card => "CA", :user => @board.user_n)
    @board.cards.create!(:card => "C4", :user => @board.user_w)

    @board.cards.create!(:card => "D8", :user => @board.user_n)
    @board.cards.create!(:card => "DA", :user => @board.user_w)
    @board.cards.create!(:card => "DJ", :user => @board.user_n)
    @board.cards.create!(:card => "D5", :user => @board.user_e)

    @board.cards.create!(:card => "H3", :user => @board.user_w)
    @board.cards.create!(:card => "H4", :user => @board.user_n)
    @board.cards.create!(:card => "HJ", :user => @board.user_e)
    @board.cards.create!(:card => "H2", :user => @board.user_n)

    @board.cards.create!(:card => "C5", :user => @board.user_e)
    @board.cards.create!(:card => "C2", :user => @board.user_n)
    @board.cards.create!(:card => "C7", :user => @board.user_w)
    @board.cards.create!(:card => "S6", :user => @board.user_n)

    @board.cards.create!(:card => "DJ", :user => @board.user_n)
    @board.cards.create!(:card => "C9", :user => @board.user_e)
    @board.cards.create!(:card => "D8", :user => @board.user_n)
    @board.cards.create!(:card => "D6", :user => @board.user_w)

    @board.cards.create!(:card => "H6", :user => @board.user_n)
    @board.cards.create!(:card => "HQ", :user => @board.user_e)
    @board.cards.create!(:card => "H8", :user => @board.user_n)
    @board.cards.create!(:card => "H5", :user => @board.user_w)

    @board.cards.create!(:card => "CJ", :user => @board.user_e)
    @board.cards.create!(:card => "C6", :user => @board.user_n)
    @board.cards.create!(:card => "C8", :user => @board.user_w)
    @board.cards.create!(:card => "S8", :user => @board.user_n)

    @board.cards.create!(:card => "H7", :user => @board.user_n)
    @board.cards.create!(:card => "HA", :user => @board.user_e)
    @board.cards.create!(:card => "HT", :user => @board.user_n)
    @board.cards.create!(:card => "D7", :user => @board.user_w)

    @board.cards.create!(:card => "H9", :user => @board.user_e)
    @board.cards.create!(:card => "CT", :user => @board.user_n)
    @board.cards.create!(:card => "CQ", :user => @board.user_w)
    @board.cards.create!(:card => "HK", :user => @board.user_n)

    # result: 1S-N +2
  end

  test "return first lead as lead" do
    lead_card = @board.cards.create!(:card => "S5", :user => @board.user_e)
    assert_equal lead_card, @board.cards.current_lead
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    assert_equal lead_card, @board.cards.current_lead
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    assert_equal lead_card, @board.cards.current_lead
  end

  test "return current trick" do
    c1 = @board.cards.create!(:card => "S5", :user => @board.user_e)
    c2 = @board.cards.create!(:card => "ST", :user => @board.user_n)
    c3 = @board.cards.create!(:card => "SJ", :user => @board.user_w)
    assert_equal [c1, c2, c3], @board.cards.current_trick.all
    c4 = @board.cards.create!(:card => "SA", :user => @board.user_n)
    assert_equal [c1, c2, c3, c4], @board.cards.previous_trick.all
  end

  test "return [] for previous trick if first trick is played" do
    @board.cards.create!(:card => "S5", :user => @board.user_e)
    assert_equal [], @board.cards.previous_trick.all
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    assert_equal [], @board.cards.previous_trick.all
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    assert_equal [], @board.cards.previous_trick.all
  end

  test "return previous trick" do
    c1 = @board.cards.create!(:card => "S5", :user => @board.user_e)
    c2 = @board.cards.create!(:card => "ST", :user => @board.user_n)
    c3 = @board.cards.create!(:card => "SJ", :user => @board.user_w)
    c4 = @board.cards.create!(:card => "SA", :user => @board.user_n)
    @board.cards.create!(:card => "SK", :user => @board.user_n)
    assert_equal [c1, c2, c3, c4], @board.cards.previous_trick.all
  end

  test "return trick suit" do
    @board.cards.create!(:card => "S5", :user => @board.user_e)
    assert_equal "S", @board.cards.current_trick_suit
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    assert_equal "S", @board.cards.current_trick_suit
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    assert_equal "S", @board.cards.current_trick_suit
  end

  test "return previous trick suit" do
    @board.cards.create!(:card => "S5", :user => @board.user_e)
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    @board.cards.create!(:card => "SA", :user => @board.user_n)
    @board.cards.create!(:card => "HK", :user => @board.user_n)
    assert_equal "S", @board.cards.previous_trick_suit
  end

  test "completed tricks count returns 1 after first trick" do
    assert_equal 0, @board.cards.completed_tricks_count
    @board.cards.create!(:card => "S5", :user => @board.user_e)
    assert_equal 0, @board.cards.completed_tricks_count
    @board.cards.create!(:card => "ST", :user => @board.user_n)
    assert_equal 0, @board.cards.completed_tricks_count
    @board.cards.create!(:card => "SJ", :user => @board.user_w)
    assert_equal 0, @board.cards.completed_tricks_count
    @board.cards.create!(:card => "SA", :user => @board.user_n)
    assert_equal 1, @board.cards.completed_tricks_count
  end
end

class CardPreviousTrickWinnerTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board_1S_by_N, :deal_id => 2354882295268699396238561385.to_s)
    # "N"=>["SA", "SK", "SJ", "ST", "S8", "S5", "DT", "D2", "CA", "C9", "C7", "C5", "C2"]
    # "E"=>["S4", "HK", "HQ", "H8", "H6", "DA", "DK", "DQ", "D9", "D6", "D4", "CJ", "C4"]
    # "S"=>["S9", "S6", "S3", "S2", "H5", "H4", "H3", "D8", "D5", "CK", "CQ", "CT", "C3"]
    # "W"=>["SQ", "S7", "HA", "HJ", "HT", "H9", "H7", "H2", "DJ", "D7", "D3", "C8", "C6"]
  end

  test "return N as trick winner when cards in one suit" do
    @board.cards.create!(:card => "CJ", :user => @board.user_e)
    @board.cards.create!(:card => "CK", :user => @board.user_n)
    @board.cards.create!(:card => "C8", :user => @board.user_w)
    @board.cards.create!(:card => "CA", :user => @board.user_n)
    assert @board.user_n, @board.cards.previous_trick_winner
  end

  test "return W as trick winner when cards in not one suit" do
    @board.cards.create!(:card => "HQ", :user => @board.user_e)
    @board.cards.create!(:card => "H5", :user => @board.user_n)
    @board.cards.create!(:card => "HA", :user => @board.user_w)
    @board.cards.create!(:card => "DT", :user => @board.user_n)
    assert @board.user_w, @board.cards.previous_trick_winner
  end

  test "return trick N as winner when trump played" do
    @board.cards.create!(:card => "HQ", :user => @board.user_e)
    @board.cards.create!(:card => "H5", :user => @board.user_n)
    @board.cards.create!(:card => "HA", :user => @board.user_w)
    @board.cards.create!(:card => "SJ", :user => @board.user_n)
    assert @board.user_n, @board.cards.previous_trick_winner
  end
end

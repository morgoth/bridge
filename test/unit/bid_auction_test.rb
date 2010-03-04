require "test_helper"

class BidAuctionTest < ActiveSupport::TestCase
  setup do
    @board = Factory(:board, :dealer => "N")
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  # UTILITIES

  test "suit and level of pass are nil" do
    bid = @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of double are nil" do
    @board.bids.create!(:bid => "1C", :user => @user_n)
    bid = @board.bids.create!(:bid => "X", :user => @user_e)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of redouble are nil" do
    @board.bids.create!(:bid => "1C", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    bid = @board.bids.create!(:bid => "XX", :user => @user_s)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of 5H are correct" do
    bid = @board.bids.create!(:bid => "5H", :user => @user_n)
    assert_equal "H", bid.suit
    assert_equal "5", bid.level
  end

  test "suit and level of 7NT are correct" do
    bid = @board.bids.create!(:bid => "7NT", :user => @user_n)
    assert_equal "NT", bid.suit
    assert_equal "7", bid.level
  end

  test "partners_bid? returns valid results" do
    bid1 = @board.bids.create!(:bid => "1S", :user => @user_n)
    bid2 = @board.bids.create!(:bid => "PASS", :user => @user_e)
    bid3 = @board.bids.build(:bid => "1NT", :user => @user_s)
    assert bid1.send(:partners_bid?, bid3)
    assert bid3.send(:partners_bid?, bid1)
    assert_false bid2.send(:partners_bid?, bid1)
    assert_false bid1.send(:partners_bid?, bid2)
    assert_false bid2.send(:partners_bid?, bid3)
    assert_false bid3.send(:partners_bid?, bid2)
  end

  test "partners_bid? returns valid results when saved" do
    bid1 = @board.bids.create!(:bid => "1S", :user => @user_n)
    bid2 = @board.bids.create!(:bid => "PASS", :user => @user_e)
    bid3 = @board.bids.create!(:bid => "1NT", :user => @user_s)
    assert bid1.send(:partners_bid?, bid3)
    assert bid3.send(:partners_bid?, bid1)
    assert_false bid2.send(:partners_bid?, bid1)
    assert_false bid1.send(:partners_bid?, bid2)
    assert_false bid2.send(:partners_bid?, bid3)
    assert_false bid3.send(:partners_bid?, bid2)
  end

  test "active returns only bids beginning from the last contract" do
    @board.bids.create!(:bid => "1C", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    bid1 = @board.bids.create!(:bid => "1H", :user => @user_w)
    bid2 = @board.bids.create!(:bid => "X", :user => @user_n)
    bid3 = @board.bids.create!(:bid => "XX", :user => @user_e)
    assert_equal [bid1, bid2, bid3], @board.bids.active.all
  end

  test "with suit returns bids of given suit" do
    @board.bids.create!(:bid => "1C", :user => @user_n)
    @board.bids.create!(:bid => "1D", :user => @user_e)
    @board.bids.create!(:bid => "1H", :user => @user_s)
    @board.bids.create!(:bid => "1S", :user => @user_w)
    bid1 = @board.bids.create!(:bid => "1NT", :user => @user_n)
    @board.bids.create!(:bid => "2C", :user => @user_e)
    @board.bids.create!(:bid => "2D", :user => @user_s)
    @board.bids.create!(:bid => "2H", :user => @user_w)
    @board.bids.create!(:bid => "2S", :user => @user_n)
    bid2 = @board.bids.create!(:bid => "2NT", :user => @user_e)
    assert_equal [bid1, bid2], @board.bids.with_suit("NT").all
  end

  test "of side returns bids of given bid's side only" do
    bid1 = @board.bids.create!(:bid => "1C", :user => @user_n)
    @board.bids.create!(:bid => "1D", :user => @user_e)
    bid2 = @board.bids.create!(:bid => "1H", :user => @user_s)
    @board.bids.create!(:bid => "1S", :user => @user_w)
    assert_equal [bid1, bid2], @board.bids.of_side(bid1)
    assert_equal [bid1, bid2], @board.bids.of_side(bid2)
  end

  test "final returns bids of last contract side and suit" do
    @board.bids.create!(:bid => "1C", :user => @user_n)
    @board.bids.create!(:bid => "1H", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "1S", :user => @user_w)
    bid1 = @board.bids.create!(:bid => "2S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "3NT", :user => @user_s)
    @board.bids.create!(:bid => "X", :user => @user_w)
    @board.bids.create!(:bid => "4H", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    bid2 = @board.bids.create!(:bid => "4S", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)

    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    assert_equal [bid1, bid2], @board.bids.final.all
  end

  test "set contract after auction complete" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    assert_nil @board.contract
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_equal "1SX", @board.reload.contract
  end

  test "set declarer after auction complete" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    assert_nil @board.contract
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_equal "N", @board.reload.declarer
  end
  # CONTRACT

  test "bid lower than the last contract is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "1H", :user => @user_e)
    end
  end

  test "bid equal to the last contract is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "1S", :user => @user_e)
    end
  end

  # DOUBLE

  test "doubling partner's contract is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_s)
    end
  end

  test "doubling when no contract bid has been made is invalid" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_e)
    end
  end

  test "doubling partner's double is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_w)
    end
  end

  test "doubling opponent's double is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_s)
    end
  end

  test "doubling partner's redouble is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_n)
    end
  end

  test "doubling opponent's redouble is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "X", :user => @user_w)
    end
  end

  # REDOUBLE

  test "redoubling when no double bid has been made is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "XX", :user => @user_e)
    end
  end

  test "redoubling when no contract bid has been made is invalid" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "XX", :user => @user_e)
    end
  end

  test "redoubling partner's double is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "XX", :user => @user_w)
    end
  end

  test "redoubling partner's redouble is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "XX", :user => @user_n)
    end
  end

  test "redoubling opponent's redouble is invalid" do
    @board.bids.create!(:bid => "1S", :user => @user_n)
    @board.bids.create!(:bid => "X", :user => @user_e)
    @board.bids.create!(:bid => "XX", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:bid => "XX", :user => @user_w)
    end
  end

  test "four passes are valid" do
    @board.bids.create!(:bid => "PASS", :user => @user_n)
    @board.bids.create!(:bid => "PASS", :user => @user_e)
    @board.bids.create!(:bid => "PASS", :user => @user_s)
    @board.bids.create!(:bid => "PASS", :user => @user_w)
  end
end

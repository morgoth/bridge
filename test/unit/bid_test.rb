require 'test_helper'

class BidValidationTest < ActiveSupport::TestCase
  def setup
    @board = Factory(:board)
    @bid = Factory.build(:bid, :board => @board)
  end

  test "is valid with valid attributes" do
    assert @bid.valid?
  end

  test "saves correctly with valid attributes" do
    assert @bid.save
  end

  test "is invalid without a value" do
    @bid.value = nil
    assert @bid.invalid?
  end

  test "is invalid without a board" do
    @bid.board = nil
    assert @bid.invalid?
  end

  test "is invalid with invalid value" do
    @bid.value = "pas"
    assert @bid.invalid?
  end
end

class BiddingTest < ActiveSupport::TestCase
  def setup
    @board = Factory(:board, :dealer => "N")
    @user_n = @board.user_n
    @user_e = @board.user_e
    @user_s = @board.user_s
    @user_w = @board.user_w
  end

  # UTILITIES

  test "suit and level of pass are nil" do
    bid = @board.bids.create!(:value => "PASS", :user => @user_n)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of double are nil" do
    @board.bids.create!(:value => "1C", :user => @user_n)
    bid = @board.bids.create!(:value => "X", :user => @user_e)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of redouble are nil" do
    @board.bids.create!(:value => "1C", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    bid = @board.bids.create!(:value => "XX", :user => @user_s)
    assert_nil bid.suit
    assert_nil bid.level
  end

  test "suit and level of 5H are correct" do
    bid = @board.bids.create!(:value => "5H", :user => @user_n)
    assert_equal "H", bid.suit
    assert_equal "5", bid.level
  end

  test "suit and level of 7NT are correct" do
    bid = @board.bids.create!(:value => "7NT", :user => @user_n)
    assert_equal "NT", bid.suit
    assert_equal "7", bid.level
  end

  test "partners_bid? returns valid results" do
    bid1 = @board.bids.create!(:value => "1S", :user => @user_n)
    bid2 = @board.bids.create!(:value => "PASS", :user => @user_e)
    bid3 = @board.bids.build(:value => "1NT", :user => @user_s)
    assert bid1.partners_bid?(bid3)
    assert bid3.partners_bid?(bid1)
    assert_false bid2.partners_bid?(bid1)
    assert_false bid1.partners_bid?(bid2)
    assert_false bid2.partners_bid?(bid3)
    assert_false bid3.partners_bid?(bid2)
  end

  test "partners_bid? returns valid results when saved" do
    bid1 = @board.bids.create!(:value => "1S", :user => @user_n)
    bid2 = @board.bids.create!(:value => "PASS", :user => @user_e)
    bid3 = @board.bids.create!(:value => "1NT", :user => @user_s)
    assert bid1.partners_bid?(bid3)
    assert bid3.partners_bid?(bid1)
    assert_false bid2.partners_bid?(bid1)
    assert_false bid1.partners_bid?(bid2)
    assert_false bid2.partners_bid?(bid3)
    assert_false bid3.partners_bid?(bid2)
  end

  test "active returns only bids beginning from the last contract" do
    @board.bids.create!(:value => "1C", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "XX", :user => @user_s)
    bid1 = @board.bids.create!(:value => "1H", :user => @user_w)
    bid2 = @board.bids.create!(:value => "X", :user => @user_n)
    bid3 = @board.bids.create!(:value => "XX", :user => @user_e)
    assert_equal [bid1, bid2, bid3], @board.bids.active.all
  end

  test "with suit returns bids of given suit" do
    @board.bids.create!(:value => "1C", :user => @user_n)
    @board.bids.create!(:value => "1D", :user => @user_e)
    @board.bids.create!(:value => "1H", :user => @user_s)
    @board.bids.create!(:value => "1S", :user => @user_w)
    bid1 = @board.bids.create!(:value => "1NT", :user => @user_n)
    @board.bids.create!(:value => "2C", :user => @user_e)
    @board.bids.create!(:value => "2D", :user => @user_s)
    @board.bids.create!(:value => "2H", :user => @user_w)
    @board.bids.create!(:value => "2S", :user => @user_n)
    bid2 = @board.bids.create!(:value => "2NT", :user => @user_e)
    assert_equal [bid1, bid2], @board.bids.with_suit("NT")
  end

  test "of side returns bids of given bid's side only" do
    bid1 = @board.bids.create!(:value => "1C", :user => @user_n)
    @board.bids.create!(:value => "1D", :user => @user_e)
    bid2 = @board.bids.create!(:value => "1H", :user => @user_s)
    @board.bids.create!(:value => "1S", :user => @user_w)
    assert_equal [bid1, bid2], @board.bids.of_side(bid1)
    assert_equal [bid1, bid2], @board.bids.of_side(bid2)
  end

  test "final returns bids of last contract side and suit" do
    @board.bids.create!(:value => "1C", :user => @user_n)
    @board.bids.create!(:value => "1H", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    @board.bids.create!(:value => "1S", :user => @user_w)
    bid1 = @board.bids.create!(:value => "2S", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    @board.bids.create!(:value => "3NT", :user => @user_s)
    @board.bids.create!(:value => "X", :user => @user_w)
    @board.bids.create!(:value => "4H", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    bid2 = @board.bids.create!(:value => "4S", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)

    @board.bids.create!(:value => "PASS", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    assert_equal [bid1, bid2], @board.bids.final.all
  end

  # CONTRACT

  test "bid lower than the last contract is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "1H", :user => @user_e)
    end
  end

  test "bid equal to the last contract is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "1S", :user => @user_e)
    end
  end

  # DOUBLE

  test "doubling partner's contract is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_s)
    end
  end

  test "doubling when no contract bid has been made is invalid" do
    @board.bids.create!(:value => "PASS", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_e)
    end
  end

  test "doubling partner's double is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_w)
    end
  end

  test "doubling opponent's double is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_s)
    end
  end

  test "doubling partner's redouble is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "XX", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_n)
    end
  end

  test "doubling opponent's redouble is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "XX", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X", :user => @user_w)
    end
  end

  # REDOUBLE

  test "redoubling when no double bid has been made is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX", :user => @user_e)
    end
  end

  test "redoubling when no contract bid has been made is invalid" do
    @board.bids.create!(:value => "PASS", :user => @user_n)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX", :user => @user_e)
    end
  end

  test "redoubling partner's double is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX", :user => @user_w)
    end
  end

  test "redoubling partner's redouble is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "XX", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX", :user => @user_n)
    end
  end

  test "redoubling opponent's redouble is invalid" do
    @board.bids.create!(:value => "1S", :user => @user_n)
    @board.bids.create!(:value => "X", :user => @user_e)
    @board.bids.create!(:value => "XX", :user => @user_s)
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX", :user => @user_w)
    end
  end

  test "four passes are valid" do
    @board.bids.create!(:value => "PASS", :user => @user_n)
    @board.bids.create!(:value => "PASS", :user => @user_e)
    @board.bids.create!(:value => "PASS", :user => @user_s)
    @board.bids.create!(:value => "PASS", :user => @user_w)
  end
end

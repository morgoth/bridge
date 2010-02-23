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
    @board = Factory(:board)
  end

  # UTILITIES

  test "partners_bid? returns valid results" do
    bid1 = @board.bids.create!(:value => "1S")
    bid2 = @board.bids.create!(:value => "PASS")
    bid3 = @board.bids.build(:value => "1NT")
    assert bid1.partners_bid?(bid3)
    assert bid3.partners_bid?(bid1)
    assert_false bid2.partners_bid?(bid1)
    assert_false bid1.partners_bid?(bid2)
    assert_false bid2.partners_bid?(bid3)
    assert_false bid3.partners_bid?(bid2)
  end

  test "partners_bid? returns valid results when saved" do
    bid1 = @board.bids.create!(:value => "1S")
    bid2 = @board.bids.create!(:value => "PASS")
    bid3 = @board.bids.create!(:value => "1NT")
    assert bid1.partners_bid?(bid3)
    assert bid3.partners_bid?(bid1)
    assert_false bid2.partners_bid?(bid1)
    assert_false bid1.partners_bid?(bid2)
    assert_false bid2.partners_bid?(bid3)
    assert_false bid3.partners_bid?(bid2)
  end

  test "active_modifiers returns only modifiers after last contract" do
    @board.bids.create!(:value => "1C")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "XX")
    @board.bids.create!(:value => "1H")
    bid1 = @board.bids.create!(:value => "X")
    bid2 = @board.bids.create!(:value => "XX")
    assert_equal [bid1, bid2], @board.bids.active_modifiers
  end

  # CONTRACT

  test "bid lower than the last contract is invalid" do
    @board.bids.create!(:value => "1S")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "1H")
    end
  end

  test "bid equal to the last contract is invalid" do
    @board.bids.create!(:value => "1S")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "1S")
    end
  end

  # DOUBLE

  test "doubling partner's contract is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  test "doubling when no contract bid has been made is invalid" do
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  test "doubling partner's double is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  test "doubling opponent's double is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  test "doubling partner's redouble is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "XX")
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  test "doubling opponent's redouble is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "XX")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "X")
    end
  end

  # REDOUBLE

  test "redoubling when no double bid has been made is invalid" do
    @board.bids.create!(:value => "1S")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX")
    end
  end

  test "redoubling when no contract bid has been made is invalid" do
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX")
    end
  end

  test "redoubling partner's double is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX")
    end
  end

  test "redoubling partner's redouble is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "XX")
    @board.bids.create!(:value => "PASS")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX")
    end
  end

  test "redoubling opponent's redouble is invalid" do
    @board.bids.create!(:value => "1S")
    @board.bids.create!(:value => "X")
    @board.bids.create!(:value => "XX")
    assert_raises(ActiveRecord::RecordInvalid) do
      @board.bids.create!(:value => "XX")
    end
  end

  test "four passes are valid" do
    @board.bids.create!(:value => "PASS")
    @board.bids.create!(:value => "PASS")
    @board.bids.create!(:value => "PASS")
    @board.bids.create!(:value => "PASS")
  end
end

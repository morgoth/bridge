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

  # CONTRACT

  test "bid lower than the last contract is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "1H").invalid?
  end

  # DOUBLE

  test "doubling partner's contract is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  test "doubling when no contract bid has been made is invalid" do
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  test "doubling partner's double is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  test "doubling opponent's double is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  test "doubling partner's redouble is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "XX").valid?
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  test "doubling opponent's redouble is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "XX").valid?
    assert @board.bids.create(:value => "X").invalid?
  end

  # REDOUBLE

  test "redoubling when no double bid has been made is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "XX").invalid?
  end

  test "redoubling when no contract bid has been made is invalid" do
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "XX").invalid?
  end

  test "redoubling partner's double is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "XX").invalid?
  end

  test "redoubling partner's redouble is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "XX").valid?
    assert @board.bids.create(:value => "PASS").valid?
    assert @board.bids.create(:value => "XX").invalid?
  end

  test "redoubling opponent's redouble is invalid" do
    assert @board.bids.create(:value => "1S").valid?
    assert @board.bids.create(:value => "X").valid?
    assert @board.bids.create(:value => "XX").valid?
    assert @board.bids.create(:value => "XX").invalid?
  end
end

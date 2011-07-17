require "test_helper"

class BidValidationTest < ActiveSupport::TestCase
  setup do
    @board = FactoryGirl.create(:board)
    @bid = FactoryGirl.build(:bid, :board => @board)
  end

  test "is valid with valid attributes" do
    assert @bid.valid?
  end

  test "saves correctly with valid attributes" do
    assert @bid.save
  end

  test "is invalid without a bid" do
    @bid.bid = nil
    assert @bid.invalid?
  end

  test "is invalid with invalid bid" do
    @bid.bid = "pas"
    assert @bid.invalid?
  end
end

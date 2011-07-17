require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  setup do
    @player = FactoryGirl.build(:player)
    @table = @player.table
    @user = @player.user
    @direction = @player.direction
  end

  test "is valid with valid attributes" do
    assert @player.valid?
  end

  test "is not valid without user" do
    @player.user = nil
    assert @player.invalid?
    assert @player.errors[:user].present?
  end

  test "is not valid without table" do
    @player.table = nil
    assert @player.invalid?
    assert @player.errors[:table].present?
  end

  test "is not valid without direction" do
    @player.direction = nil
    assert @player.invalid?
    assert @player.errors[:direction].present?
  end

  test "is not valid with invalid direction" do
    @player.direction = "H"
    assert @player.invalid?
    assert @player.errors[:direction].present?
  end

  test "is not valid with same user on same table" do
    @player.save!
    player = FactoryGirl.build(:player, :table => @table, :user => @user)
    assert player.invalid?
    assert player.errors[:user_id].present?
  end

  test "is not valid with same direction on same table" do
    @player.save!
    player = FactoryGirl.build(:player, :table => @table, :direction => @direction)
    assert player.invalid?
    assert player.errors[:direction].present?
  end
end

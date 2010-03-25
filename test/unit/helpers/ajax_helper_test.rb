require 'test_helper'

class AjaxHelperTest < ActionView::TestCase
  setup { @user = Factory(:user) }

  test "current user turn when auction" do
    board = Factory(:board, :user_n => @user)
    stubs(:current_user).returns(@user)
    assert current_user_turn?(board)
  end

  test "current user turn when current user is nil" do
    board = Factory(:board)
    stubs(:current_user).returns(nil)
    assert_false current_user_turn?(board)
  end

  test "join enabled when no player at table" do
    table = Factory :table
    stubs(:current_user).returns(@user)
    assert join_enabled?(table, "N")
  end

  test "join disabled when player present on given direction" do
    table = Factory(:table)
    Factory(:player, :table => table, :direction => "N")
    stubs(:current_user).returns(@user)
    assert_false join_enabled?(table, "N")
  end

  test "join disabled when user already sits at table" do
    table = Factory(:table)
    Factory(:player, :table => table, :direction => "N", :user => @user)
    stubs(:current_user).returns(@user)
    assert_false join_enabled?(table, "E")
  end

  test "quit enabled when user sits at given direction" do
    table = Factory(:table)
    Factory(:player, :table => table, :direction => "N", :user => @user)
    stubs(:current_user).returns(@user)
    assert quit_enabled?(table, "N")
  end

  test "quit disabled when user sits at table on other direction" do
    table = Factory(:table)
    Factory(:player, :table => table, :direction => "N", :user => @user)
    stubs(:current_user).returns(@user)
    assert_false quit_enabled?(table, "E")
  end

  test "quit disabled when user does not sit at table" do
    table = Factory(:table)
    stubs(:current_user).returns(@user)
    assert_false quit_enabled?(table, "N")
  end
end
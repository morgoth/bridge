require "test_helper"

class ClaimTest < ActiveSupport::TestCase
  setup do
    @claim = Factory.build(:claim, :board => Factory(:board_1S_by_N))
    @user_n = @declarer = @claim.board.user_n
    @user_e = @lho = @claim.board.user_e
    @user_s = @dummy = @claim.board.user_s
    @user_w = @rho = @claim.board.user_w
    @stranger = Factory(:user)
  end

  test "is valid with valid attributes" do
    assert @claim.valid?
  end

  test "claim accepted when first lead user claims" do
    @claim.user = @lho
    @claim.save!
    assert_equal "next_accepted", @claim.state
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted when partner of first lead user claims" do
    @claim.user = @rho
    @claim.save!
    assert_equal "previous_accepted", @claim.state
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted by next and then by previous when declarer claims" do
    @claim.claiming_user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert_equal "next_accepted", @claim.state
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted by previous and then by next when declarer claims" do
    @claim.claiming_user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "previous_accepted", @claim.state
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim rejected when first lead user claims" do
    @claim.user = @lho
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim rejected when partner of first lead user claims" do
    @claim.user = @rho
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim rejected when declarer claims" do
    @claim.user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim can't be accepted by wrong user" do
    @claim.user = @lho
    @claim.save!
    @claim.user = @rho
    assert_false @claim.accept
  end

  test "dummy can't claim" do
    @claim.user = @dummy
    assert @claim.invalid?
    assert @claim.errors[:user].present?
  end

  test "dummy can't reject" do
    @claim.save!
    @claim.user = @dummy
    assert_false @claim.accept
  end

  test "stranger can't claim" do
    @claim.user = @stranger
    assert @claim.invalid?
    assert @claim.errors[:user].present?
  end

  test "stranger can't reject" do
    @claim.save!
    @claim.user = @stranger
    assert_false @claim.accept
  end

  test "claiming user can reject" do
    @claim.user = @lho
    @claim.save!
    @claim.user = @lho
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "claiming user's partner can reject" do
    @claim.user = @lho
    @claim.save!
    @claim.user = @rho
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "claiming user's opponent can reject" do
    @claim.user = @lho
    @claim.save!
    @claim.user = @declarer
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "concerned_users skips dummy when declarer claims" do
    @claim.user = @declarer
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@lho)
    assert       @claim.concerned_users.include?(@rho)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "accept_users skips dummy and claiming_user when declarer claims" do
    @claim.user = @declarer
    @claim.save!
    assert_false @claim.accept_users.include?(@declarer)
    assert       @claim.accept_users.include?(@lho)
    assert       @claim.accept_users.include?(@rho)
    assert_false @claim.accept_users.include?(@dummy)
  end

  test "reject_users skips dummy and claiming_user when declarer claims" do
    @claim.user = @declarer
    @claim.save!
    assert_false @claim.reject_users.include?(@declarer)
    assert       @claim.reject_users.include?(@lho)
    assert       @claim.reject_users.include?(@rho)
    assert_false @claim.reject_users.include?(@dummy)
  end

  test "concerned_users skips dummy and next player when declarer claims and next player accepted" do
    @claim.user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert       @claim.concerned_users.include?(@declarer)
    assert_false @claim.concerned_users.include?(@lho)
    assert       @claim.concerned_users.include?(@rho)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users skips dummy and previous player when declarer claims and previous player accepted" do
    @claim.user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@lho)
    assert_false @claim.concerned_users.include?(@rho)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users returns declarer and claiming user only if lho player claims" do
    @claim.user = @lho
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@lho)
    assert_false @claim.concerned_users.include?(@rho)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users returns declarer and claiming user only if rho player claims" do
    @claim.user = @rho
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert_false @claim.concerned_users.include?(@lho)
    assert       @claim.concerned_users.include?(@rho)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "return declarer_total_tricks when declarer claims" do
    # trcik taken by declarer
    @claim.board.cards.create!(:card => "H2", :user => @claim.board.user_e)
    @claim.board.cards.create!(:card => "D2", :user => @claim.board.user_n)
    @claim.board.cards.create!(:card => "C2", :user => @claim.board.user_w)
    @claim.board.cards.create!(:card => "S2", :user => @claim.board.user_n)

    @claim.claiming_user = @declarer
    @claim.tricks = 10
    assert_equal @claim.declarer_total_tricks, 11
  end

  test "return declarer_total_tricks when lho claims" do
    # trick taken by declarer
    @claim.board.cards.create!(:card => "H2", :user => @claim.board.user_e)
    @claim.board.cards.create!(:card => "D2", :user => @claim.board.user_n)
    @claim.board.cards.create!(:card => "C2", :user => @claim.board.user_w)
    @claim.board.cards.create!(:card => "S2", :user => @claim.board.user_n)

    @claim.claiming_user = @lho
    @claim.tricks = 10
    assert_equal @claim.declarer_total_tricks, 3
  end
end

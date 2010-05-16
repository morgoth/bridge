require "test_helper"

class ClaimTest < ActiveSupport::TestCase
  setup do
    @claim = Factory.build(:claim, :board => Factory(:board_1S_by_N))
    @user_n = @declarer = @claim.board.user_n
    @user_e = @first_lead = @claim.board.user_e
    @user_s = @dummy = @claim.board.user_s
    @user_w = @first_lead_partner = @claim.board.user_w
    @stranger = Factory(:user)
  end

  test "is valid with valid attributes" do
    assert @claim.valid?
  end

  test "claim accepted when first lead user claims" do
    @claim.user = @first_lead
    @claim.save!
    assert_equal "next_accepted", @claim.state
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted when partner of first lead user claims" do
    @claim.user = @first_lead_partner
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
    @claim.user = @first_lead
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim rejected when partner of first lead user claims" do
    @claim.user = @first_lead_partner
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
    @claim.user = @first_lead
    @claim.save!
    @claim.user = @first_lead_partner
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
    @claim.user = @first_lead
    @claim.save!
    @claim.user = @first_lead
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "claiming user's partner can reject" do
    @claim.user = @first_lead
    @claim.save!
    @claim.user = @first_lead_partner
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "claiming user's opponent can reject" do
    @claim.user = @first_lead
    @claim.save!
    @claim.user = @declarer
    assert @claim.reject
    assert_equal "rejected", @claim.state
  end

  test "concerned_users skips dummy when declarer claims" do
    @claim.user = @declarer
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@first_lead)
    assert       @claim.concerned_users.include?(@first_lead_partner)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned users skips dummy and next player when declarer claims and next player accepted" do
    @claim.user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert       @claim.concerned_users.include?(@declarer)
    assert_false @claim.concerned_users.include?(@first_lead)
    assert       @claim.concerned_users.include?(@first_lead_partner)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users skips dummy and previous player when declarer claims and previous player accepted" do
    @claim.user = @declarer
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@first_lead)
    assert_false @claim.concerned_users.include?(@first_lead_partner)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users returns declarer and claiming user only if first_lead player claims" do
    @claim.user = @first_lead
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert       @claim.concerned_users.include?(@first_lead)
    assert_false @claim.concerned_users.include?(@first_lead_partner)
    assert_false @claim.concerned_users.include?(@dummy)
  end

  test "concerned_users returns declarer and claiming user only if first_lead_partner player claims" do
    @claim.user = @first_lead_partner
    @claim.save!
    assert       @claim.concerned_users.include?(@declarer)
    assert_false @claim.concerned_users.include?(@first_lead)
    assert       @claim.concerned_users.include?(@first_lead_partner)
    assert_false @claim.concerned_users.include?(@dummy)
  end
end

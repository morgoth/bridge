require "test_helper"

class ClaimTest < ActiveSupport::TestCase
  setup do
    @claim = Factory.build(:claim, :board => Factory(:board_1S_by_N))
  end

  test "is valid with valid attributes" do
    assert @claim.valid?
  end

  test "claim accepted when first lead user claims" do
    @claim.claiming_user = @claim.board.user_e
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted when partner of first lead user claims" do
    @claim.claiming_user = @claim.board.user_w
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim accepted when declarer claims" do
    @claim.claiming_user = @claim.board.user_n
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept!
    @claim.user = @claim.claiming_user.previous
    @claim.accept!
    assert_equal "accepted", @claim.state
  end

  test "claim rejected when first lead user claims" do
    @claim.claiming_user = @claim.board.user_e
    @claim.save!
    @claim.user = @claim.claiming_user.previous
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim rejected when partner of first lead user claims" do
    @claim.claiming_user = @claim.board.user_w
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim rejected when declarer claims" do
    @claim.claiming_user = @claim.board.user_n
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.reject!
    assert_equal "rejected", @claim.state
  end

  test "claim not transist when wrong user is set" do
    @claim.claiming_user = @claim.board.user_e
    @claim.save!
    @claim.user = @claim.claiming_user.next
    @claim.accept
    assert_false "accepted" == @claim.state
  end
end

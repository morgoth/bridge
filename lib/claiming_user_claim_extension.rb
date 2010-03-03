module ClaimingUserClaimExtension
  include UserExtension

  def direction
    board.users.find { |user| user == proxy_target }.direction
  end

  private

  def board
    proxy_owner.board
  end
end

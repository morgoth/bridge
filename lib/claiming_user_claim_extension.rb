module ClaimingUserClaimExtension
  def next_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i + 1) % 4]
  end

  def next
    proxy_owner.board.send("user_#{next_direction.downcase}")
  end

  def previous_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i - 1) % 4]
  end

  def previous
    proxy_owner.board.send("user_#{previous_direction.downcase}")
  end

  def direction
    board.users.find { |user| user == proxy_target }
  end

  def first_lead?
    proxy_owner.board.first_lead_user == proxy_target
  end

  def declarer?
    proxy_owner.board.declarer_user == proxy_target
  end

  def dummy?
    proxy_owner.board.dummy_user == proxy_target
  end
end

module UserBoardExtension
  def next_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i + 1) % 4]
  end

  def partner
    self.next.next
  end

  def next
    proxy_owner.send("user_#{next_direction.downcase}")
  end

  def previous_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i - 1) % 4]
  end

  def previous
    proxy_owner.send("user_#{previous_direction.downcase}")
  end

  def direction
    proxy_reflection.name.to_s[-1].upcase
  end

  def first_lead?
    proxy_owner.first_lead_user == proxy_target
  end

  def declarer?
    proxy_owner.declarer_user == proxy_target
  end

  def dummy?
    proxy_owner.dummy_user == proxy_target
  end

  def has_card?(card)
    proxy_owner.deal[direction].include?(card)
  end

  def has_cards_in_suit?(suit)
    proxy_owner.cards_left(direction).any? { |c| c.suit == suit }
  end
end

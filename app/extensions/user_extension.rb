module UserExtension
  def next_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i + 1) % 4]
  end

  def partner
    self.next.next
  end

  def next
    board.send("user_#{next_direction.downcase}")
  end

  def previous_direction
    i = Bridge::DIRECTIONS.index(direction)
    next_direction = Bridge::DIRECTIONS[(i - 1) % 4]
  end

  def previous
    board.send("user_#{previous_direction.downcase}")
  end

  def first_lead?
    board.first_lead_user == proxy_target
  end

  def declarer?
    board.declarer_user == proxy_target
  end

  def dummy?
    board.dummy_user == proxy_target
  end

  def has_card?(card)
    board.deal[direction].include?(card)
  end

  def has_cards_in_suit?(suit)
    board.cards_left(direction).any? { |c| c.suit == suit }
  end
end

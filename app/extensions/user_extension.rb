module UserExtension
  def next_direction
    i = Bridge::DIRECTIONS.index(direction)
    Bridge::DIRECTIONS[(i + 1) % 4]
  end

  def partner
    self.next.next
  end

  def next
    board.send("user_#{next_direction.downcase}")
  end

  def previous_direction
    i = Bridge::DIRECTIONS.index(direction)
    Bridge::DIRECTIONS[(i - 1) % 4]
  end

  def previous
    board.send("user_#{previous_direction.downcase}")
  end

  def left_hand_oponent?
    board.users.lho == self
  end
  alias lho? left_hand_oponent?

  def declarer?
    board.users.declarer == self
  end

  def dummy?
    board.users.dummy == self
  end

  def has_card?(card)
    board.deal[direction].include?(card)
  end

  def has_cards_in_suit?(suit)
    board.cards_left[direction].any? { |c| Bridge::Card.new(c).suit == suit }
  end

  def cards_left
    board.cards_left[direction]
  end
end

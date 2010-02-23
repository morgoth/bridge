module UserBoardExtension
  DIRECTIONS = %w(N E S W)

  def next_direction
    i = DIRECTIONS.index(direction)
    next_direction = DIRECTIONS[(i + 1) % 4]
  end

  def next
    proxy_owner.send("user_#{next_direction.downcase}")
  end

  def previous_direction
    i = DIRECTIONS.index(direction)
    next_direction = DIRECTIONS[(i - 1) % 4]
  end

  def previous
    proxy_owner.send("user_#{previous_direction.downcase}")
  end

  def direction
    proxy_reflection.name.to_s[-1].upcase
  end
end
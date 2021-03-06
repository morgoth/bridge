module UsersBoardExtension
  def [](i)
    direction = i.to_s.upcase
    if Bridge.direction?(direction)
      j = Bridge::DIRECTIONS.index(direction)
      proxy_target[j]
    else
      proxy_target[i]
    end
  end

  %w(n e s w).each do |direction|
    define_method(direction) { self[direction] }
  end

  def without_dummy
    proxy_target.reject { |user| user.dummy? }
  end

  def dealer
    self[proxy_owner.dealer]
  end

  def declarer
    self[proxy_owner.declarer]
  end

  def left_hand_oponent
    declarer.next
  end
  alias lho left_hand_oponent

  def right_hand_oponent
    declarer.previous
  end
  alias rho right_hand_oponent

  def dummy
    declarer.partner
  end

  def owner(card)
    direction = proxy_owner.deal_owner(card)
    self[direction]
  end
end

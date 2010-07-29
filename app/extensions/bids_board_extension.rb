module BidsBoardExtension
  # active means beginning from the last contract
  def active
    where("position >= ?", contracts.last.try(:position) || 1)
  end

  def final
    with_suit(contracts.last).of_side(contracts.last)
  end

  def current_position
    count + 1
  end

  def current_contract
    contracts.last
  end

  def current_modifier
    active.modifiers.last
  end

  def current_double
    active.doubles.last
  end

  def current_redouble
    active.redoubles.last
  end

  def partners_bid?(bid)
    current_position % 2 == bid.position % 2
  end

  def current_user
    if current_position == 1
      proxy_owner.users.dealer
    else
      last.user.next
    end
  end

  def double_allowed?
    !!(current_contract && !partners_bid?(current_contract) && !current_modifier)
  end

  def redouble_allowed?
    !!(current_double && !partners_bid?(current_double) && !current_redouble)
  end
end

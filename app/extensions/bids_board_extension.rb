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

  def current_user
    if current_position == 1
      proxy_owner.dealer
    else
      last.user.next
    end
  end
end

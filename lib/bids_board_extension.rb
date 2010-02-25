module BidsBoardExtension
  # active means beginning from the last contract
  def active
    where("position >= ?", contracts.last.try(:position) || 1)
  end

  def final
    with_suit(contracts.last).of_side(contracts.last)
  end
end

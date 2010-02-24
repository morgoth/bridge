module UsersBoardExtension
  def [](i)
    direction = i.to_s.upcase
    if Bridge.direction?(direction)
      j = Bridge::DIRECTIONS.index(direction)
      Array.new(self)[j]
    else
      Array.new(self)[i]
    end
  end

  def n
    self["N"]
  end

  def e
    self["E"]
  end

  def s
    self["S"]
  end

  def w
    self["W"]
  end
end

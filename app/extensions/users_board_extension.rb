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

  %w(n e s w).each do |direction|
    define_method(direction) { self[direction] }
  end

  def without_dummy
    reject { |user| user.dummy? }
  end
end

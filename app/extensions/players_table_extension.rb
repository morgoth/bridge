module PlayersTableExtension
  %w(n e s w).each do |direction|
    define_method(direction) do
      where(:direction => direction.upcase).first
    end
  end

  def for(user)
    user && where(:user_id => user.id).first
  end

  def [](direction)
    send(direction.to_s.downcase)
  end
end

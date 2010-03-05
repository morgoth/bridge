Factory.define :table do |table|

end

Factory.define :table_with_players, :parent => :table do |table|
  table.after_create do |t|
    %w(N E S W).map { |direction| Factory(:player, :direction => direction, :table => t) }
  end
end

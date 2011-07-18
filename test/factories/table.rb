FactoryGirl.define do
  factory :table do
  end

  factory :table_with_players, :parent => :table do
    after_create do |table|
      %w(N E S W).map { |direction| FactoryGirl.create(:player, :direction => direction, :table => table) }
    end
  end
end

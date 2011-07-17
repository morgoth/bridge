FactoryGirl.define do
  factory :card do
    association :board, :factory => :board_1S_by_N
    card "SA"
    user { board.users.lho }
  end
end

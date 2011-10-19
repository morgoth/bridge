FactoryGirl.define do
  factory :card do
    association :board, :factory => :board_1s_by_n
    card "SA"
    user { board.users.lho }
  end
end

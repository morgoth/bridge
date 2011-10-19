FactoryGirl.define do
  factory :claim do
    association :board, :factory => :board_1s_by_n
    tricks 13
    user { board.user_n }
  end

  factory :accepted_claim, :parent => :claim do
    after_create do |claim|
      claim.user = claim.board.user_e
      claim.accept!
      claim.user = claim.board.user_w
      claim.accept!
      claim.reload
      claim.board.reload
    end
  end
end

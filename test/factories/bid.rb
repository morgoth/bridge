FactoryGirl.define do
  factory :bid do
    board
    bid "PASS"
    user { current_user }
  end
end

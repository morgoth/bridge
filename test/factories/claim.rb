Factory.define :claim do |claim|
  claim.association :board, :factory => :board_1S_by_N
  claim.claim
  claim.claiming_user { |c| c.expected_user }
end

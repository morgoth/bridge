Factory.define :claim do |claim|
  claim.association :board, :factory => :board_1S_by_N
  claim.tricks 13
  claim.claiming_user { |c| c.current_user }
end

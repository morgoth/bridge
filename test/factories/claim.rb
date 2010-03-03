Factory.define :claim do |claim|
  claim.association :board, :factory => :board_1S_by_N
  claim.tricks 13
  claim.user { |c| c.board.user_n }
end

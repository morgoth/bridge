Factory.define :claim do |claim|
  claim.association :board, :factory => :board_1S_by_N
  claim.tricks 13
  claim.user { |c| c.board.user_n }
end

Factory.define :accepted_claim, :parent => :claim do |claim|
  claim.after_create do |c|
    c.user = c.board.user_e
    c.accept!
    c.user = c.board.user_w
    c.accept!
    c.reload
    c.board.reload
  end
end

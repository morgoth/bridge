Factory.define :card do |c|
  c.association :board, :factory => :board_1S_by_N
  c.card "SA"
  c.user { |c| c.board.users.lho }
end

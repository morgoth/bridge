Factory.define :bid do |b|
  b.association :board
  b.value "PASS"
  b.user { |c| c.board.bids.user(1) }
end

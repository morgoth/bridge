Factory.define :bid do |b|
  b.association :board
  b.value "PASS"
  b.user { |c| c.board.nth_bid_user(1) }
end

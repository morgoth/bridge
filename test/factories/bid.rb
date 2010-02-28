Factory.define :bid do |bid|
  bid.association :board
  bid.bid "PASS"
  bid.user { |b| b.current_user }
end

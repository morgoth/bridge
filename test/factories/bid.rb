Factory.define :bid do |b|
  b.association :board
  # b.value "PASS"
  b.bid "PASS"
  b.user { |c| c.expected_user }
end

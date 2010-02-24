Factory.define :bid do |b|
  b.association :board
  b.value "PASS"
  b.user { |c| c.user }
end

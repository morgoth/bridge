Factory.define :player do |player|
  player.association :user
  player.association :table
  player.direction "N"
end

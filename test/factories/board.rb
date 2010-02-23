Factory.define :board do |b|
  b.association :user_n, :factory => :user
  b.association :user_e, :factory => :user
  b.association :user_s, :factory => :user
  b.association :user_w, :factory => :user
  b.deal_id "0"
  b.vulnerable "none"
  b.dealer "n"
end

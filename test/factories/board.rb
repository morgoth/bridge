Factory.define :board do |b|
  b.association :user_n, :factory => :user
  b.association :user_e, :factory => :user
  b.association :user_s, :factory => :user
  b.association :user_w, :factory => :user
  b.deal_id "0"
  b.vulnerable "none"
  b.dealer "N"
end

Factory.define :board_1S_by_N, :parent => :board do |f|
  f.after_create do |board|
    board.bids.create!(:bid => "1S", :user => board.user_n)
    board.bids.create!(:bid => "PASS", :user => board.user_e)
    board.bids.create!(:bid => "PASS", :user => board.user_s)
    board.bids.create!(:bid => "PASS", :user => board.user_w)
  end
end

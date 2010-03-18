# "N" => ["SA", "SK", "SQ", "SJ", "ST", "S9", "S8", "S7", "S6", "S5", "S4", "S3", "S2"]
# "E" => ["HA", "HK", "HQ", "HJ", "HT", "H9", "H8", "H7", "H6", "H5", "H4", "H3", "H2"]
# "S" => ["DA", "DK", "DQ", "DJ", "DT", "D9", "D8", "D7", "D6", "D5", "D4", "D3", "D2"]
# "W" => ["CA", "CK", "CQ", "CJ", "CT", "C9", "C8", "C7", "C6", "C5", "C4", "C3", "C2"]
Factory.define :board do |b|
  b.association :user_n, :factory => :user
  b.association :user_e, :factory => :user
  b.association :user_s, :factory => :user
  b.association :user_w, :factory => :user
  b.deal_id "0"
  b.vulnerable "NONE"
  b.dealer "N"
end

Factory.define :board_four_passes, :parent => :board do |f|
  f.after_create do |board|
    board.bids.create!(:bid => "PASS", :user => board.user_n)
    board.bids.create!(:bid => "PASS", :user => board.user_e)
    board.bids.create!(:bid => "PASS", :user => board.user_s)
    board.bids.create!(:bid => "PASS", :user => board.user_w)
    board.reload
  end
end

Factory.define :board_1S_by_N, :parent => :board do |f|
  f.after_create do |board|
    board.bids.create!(:bid => "1S", :user => board.user_n)
    board.bids.create!(:bid => "PASS", :user => board.user_e)
    board.bids.create!(:bid => "PASS", :user => board.user_s)
    board.bids.create!(:bid => "PASS", :user => board.user_w)
    board.reload
  end
end

# "N" => ["SA", "SK", "SQ", "S8", "S6", "HK", "H7", "H6", "H4", "DK", "DQ", "DJ", "C3"]
# "E" => ["S5", "S4", "S3", "HA", "HQ", "HJ", "H9", "D5", "D4", "CK", "CJ", "C9", "C5"]
# "S" => ["ST", "S7", "S2", "HT", "H8", "H2", "DT", "D8", "D3", "CA", "CT", "C6", "C2"]
# "W" => ["SJ", "S9", "H5", "H3", "DA", "D9", "D7", "D6", "D2", "CQ", "C8", "C7", "C4"]
Factory.define :full_board, :parent => :board do |f|
  f.deal_id 636839108127179982824423290.to_s
  f.dealer "N"
  f.after_create do |board|
    board.bids.create!(:bid => "1S", :user => board.user_n)
    board.bids.create!(:bid => "PASS", :user => board.user_e)
    board.bids.create!(:bid => "PASS", :user => board.user_s)
    board.bids.create!(:bid => "PASS", :user => board.user_w)
    # contract: 1S by N

    board.cards.create!(:card => "S5", :user => board.user_e)
    board.cards.create!(:card => "ST", :user => board.user_n)
    board.cards.create!(:card => "SJ", :user => board.user_w)
    board.cards.create!(:card => "SA", :user => board.user_n)

    board.cards.create!(:card => "SK", :user => board.user_n)
    board.cards.create!(:card => "S3", :user => board.user_e)
    board.cards.create!(:card => "S2", :user => board.user_n)
    board.cards.create!(:card => "S9", :user => board.user_w)

    board.cards.create!(:card => "SQ", :user => board.user_n)
    board.cards.create!(:card => "S4", :user => board.user_e)
    board.cards.create!(:card => "S7", :user => board.user_n)
    board.cards.create!(:card => "D2", :user => board.user_w)

    board.cards.create!(:card => "DK", :user => board.user_n)
    board.cards.create!(:card => "D4", :user => board.user_e)
    board.cards.create!(:card => "D3", :user => board.user_n)
    board.cards.create!(:card => "D9", :user => board.user_w)

    board.cards.create!(:card => "C3", :user => board.user_n)
    board.cards.create!(:card => "CK", :user => board.user_e)
    board.cards.create!(:card => "CA", :user => board.user_n)
    board.cards.create!(:card => "C4", :user => board.user_w)

    board.cards.create!(:card => "D8", :user => board.user_n)
    board.cards.create!(:card => "DA", :user => board.user_w)
    board.cards.create!(:card => "DJ", :user => board.user_n)
    board.cards.create!(:card => "D5", :user => board.user_e)

    board.cards.create!(:card => "H3", :user => board.user_w)
    board.cards.create!(:card => "H4", :user => board.user_n)
    board.cards.create!(:card => "HJ", :user => board.user_e)
    board.cards.create!(:card => "H2", :user => board.user_n)

    board.cards.create!(:card => "C5", :user => board.user_e)
    board.cards.create!(:card => "C2", :user => board.user_n)
    board.cards.create!(:card => "C7", :user => board.user_w)
    board.cards.create!(:card => "S6", :user => board.user_n)

    board.cards.create!(:card => "DQ", :user => board.user_n)
    board.cards.create!(:card => "C9", :user => board.user_e)
    board.cards.create!(:card => "DT", :user => board.user_n)
    board.cards.create!(:card => "D6", :user => board.user_w)

    board.cards.create!(:card => "H6", :user => board.user_n)
    board.cards.create!(:card => "HQ", :user => board.user_e)
    board.cards.create!(:card => "H8", :user => board.user_n)
    board.cards.create!(:card => "H5", :user => board.user_w)

    board.cards.create!(:card => "CJ", :user => board.user_e)
    board.cards.create!(:card => "C6", :user => board.user_n)
    board.cards.create!(:card => "C8", :user => board.user_w)
    board.cards.create!(:card => "S8", :user => board.user_n)

    board.cards.create!(:card => "H7", :user => board.user_n)
    board.cards.create!(:card => "HA", :user => board.user_e)
    board.cards.create!(:card => "HT", :user => board.user_n)
    board.cards.create!(:card => "D7", :user => board.user_w)

    board.cards.create!(:card => "H9", :user => board.user_e)
    board.cards.create!(:card => "CT", :user => board.user_n)
    board.cards.create!(:card => "CQ", :user => board.user_w)
    board.cards.create!(:card => "HK", :user => board.user_n)
    board.reload
    # result: 1S-N +2
  end
end

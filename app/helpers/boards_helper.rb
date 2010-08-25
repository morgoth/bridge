module BoardsHelper
  def group_bids(bids, dealer, filler = "&#8210;".html_safe)
    unshift = Bridge::DIRECTIONS.index(dealer)
    unshift.times { bids.unshift(filler) }
    bids.in_groups_of(4, filler)
  end

  def score_string(board)
    score = board.score ? board.score.result_string : ""
    "#{board.contract} #{board.declarer} #{score}"
  end
end

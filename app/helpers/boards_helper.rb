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

  def chicago_imp(board)
    return unless board.completed?
    ["N", "S"].include?(board.declarer) ? board.chicago_imp_ns : -board.chicago_imp_ns
  end

  def direction_classes(board, direction)
    classes = ["direction-#{direction.downcase}"]
    classes << "dealer" if board.dealer == direction
    classes << (board.direction_vulnerable?(direction) ? "vulnerable" : "not-vulnerable")
  end
end

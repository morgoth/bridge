module TableFactoriesHelper
  def table_without_board
    table = Factory(:table)
    Factory(:player, :direction => "N", :table => table)
    table.reload
  end

  def table_with_auction
    table = Factory(:table_with_players)
    board = Factory(:board, :table => table, :user_n => table.players.n.user, :user_e => table.players.e.user,
      :user_s => table.players.s.user, :user_w => table.players.w.user)
    board.bids.create!(:bid => "PASS", :user => board.user_n)
    board.bids.create!(:bid => "2H", :user => board.user_e, :alert => "Multi")
    table.reload
  end

  def table_before_first_lead
    table = Factory(:table_with_players)
    Factory(:board_1S_by_N, :table => table, :user_n => table.players.n.user, :user_e => table.players.e.user,
      :user_s => table.players.s.user, :user_w => table.players.w.user)
    table.reload
  end

  def table_with_trick
    table = Factory(:table_with_players)
    board = Factory(:board_1S_by_N, :table => table, :user_n => table.players.n.user, :user_e => table.players.e.user,
      :user_s => table.players.s.user, :user_w => table.players.w.user)
    board.cards.create!(:card => "HA", :user => board.user_e)
    board.cards.create!(:card => "D2", :user => board.user_n)
    board.cards.create!(:card => "C2", :user => board.user_w)
    board.cards.create!(:card => "S2", :user => board.user_n)
    table.reload
  end
end

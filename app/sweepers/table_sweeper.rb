class TableSweeper < ActionController::Caching::Sweeper
  observe Table, Board, Bid, Card, Claim, Player

  def after_save(record)
    table =
      case record
      when Table
        record
      when Board
        record.table
      else
        record.board.table
      end

    expire_action(:controller => "ajax/tables", :action => "show", :id => table.id)
  end
end

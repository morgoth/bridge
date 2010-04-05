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

    logger.info "********************************************************************************"
    logger.info "sweeper is running!"
    logger.info "********************************************************************************"
    expire_action(:controller => "ajax/tables", :action => "show", :id => table.id)
  end
end

class TableSweeper < ActionController::Caching::Sweeper
  observe Table, Board, Bid, Card, Claim, Player

  def after_save(record)
    remove_cache(record)
  end

  def after_destroy(record)
    remove_cache(record)
  end

  def remove_cache(record)
    table =
      case record
      when Table
        record
      when Board
        record.table
      when Player
        record.table
      else
        record.board.table
      end

    Rails.logger.info "********************************************************************************"
    Rails.logger.info "sweeper is running!"
    Rails.logger.info "********************************************************************************"
    # File.delete(Rails.root.join("tmp/cache/views/localhost.3000/ajax/tables/3.json.cache"))
    expire_action(:controller => "ajax/tables", :action => "show", :id => table.id)
  end
end

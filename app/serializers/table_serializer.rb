class TableSerializer
  attr_reader :table

  def initialize(table_id)
    @table = Table.find(table_id)
  end

  def to_json
    to_hash.to_json
  end

  def to_hash
    {
      :id      => table.id,
      :state   => table.state,
      :version => table.version,
      :players => players,
      :board   => board
    }
  end

  def players
    table.players.map do |player|
      {
        :id        => player.id,
        :name      => player.name,
        :direction => player.direction
      }
    end
  end

  def board
    board = table.board
    if board
      {
        :id         => board.id,
        :state      => board.state,
        :dealer     => board.dealer,
        :vulnerable => board.vulnerable,
        :declarer   => board.declarer,
        :contract   => board.contract,
        :deal       => board.deal.to_hash,
        :bids       => bids,
        :cards      => cards,
      }
    else
      nil
    end
  end

  def bids
    table.board.bids.map do |bid|
      {
        :id  => bid.id,
        :bid => bid.bid.to_s
      }
    end
  end

  def cards
    table.board.cards.map do |card|
      {
        :id   => card.id,
        :card => card.card.to_s
      }
    end
  end
end
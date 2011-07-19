class Serializer
  attr_reader :table, :board

  def initialize(table)
    @table = table
    @board = @table.boards.current
  end

  def config
    {
      :id            => table.id,
      :state         => table.state,
      :version       => table.version,
      :players       => players,
      :current_board => current_board
    }
  end

  def players
    table.players.map do |player|
      {
        :id   => player.id,
        :name => player.name
      }
    end
  end

  def current_board
    if board
      {
        :id         => board.id,
        :state      => board.state,
        :dealer     => board.dealer,
        :vulnerable => board.vulnerable,
        :declarer   => board.declarer,
        :contract   => board.contract,
        :bids       => bids,
        :cards      => cards,
        :deal       => deal
      }
    else
      nil
    end
  end

  def bids
    board.bids.map do |bid|
      {
        :id  => bid.id,
        :bid => bid.bid
      }
    end
  end

  def cards
    board.cards.map do |card|
      {
        :id   => card.id,
        :card => card.card
      }
    end
  end

  def deal
    {
      :n => board.deal.n,
      :e => board.deal.e,
      :s => board.deal.s,
      :w => board.deal.w
    }
  end
end

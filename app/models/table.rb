class Table < ActiveRecord::Base
  has_many :players
  has_many :boards

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players_ready?
    end
  end

  def user_player(user)
    players.where(:user_id => user.id).first
  end

  def for_ajax(options = {})
    serializable_hash(:only => [:id, :state]).tap do |hash|

      if options[:user] && user_player(options[:user])
        hash[:player] = user_player(options[:user]).direction
      end

      hash[:players] = players.map(&:for_ajax)
    end
  end

  private

  def four_players_ready?
    players.count == 4 && players.all?(&:ready?)
  end
end

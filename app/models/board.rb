class Board < ActiveRecord::Base
  DIRECTIONS = %w(N E S W)

  belongs_to :user_n, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_e, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_s, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_w, :class_name => "User", :extend => UserBoardExtension
  has_many :cards, :order => "bids.position ASC" do
    def user(position)
      proxy_owner.users[(Board::DIRECTIONS.index(proxy_owner.first_lead_user.direction) + position - 1) % 4]
    end
  end
  has_many :bids, :order => "bids.position ASC" do
    # active means beginning from the last contract
    def active
      where("position >= ?", contracts.last.try(:position) || 1)
    end

    def final
      with_suit(contracts.last).of_side(contracts.last)
    end

    def user(position)
      proxy_owner.users[(Board::DIRECTIONS.index(proxy_owner.dealer) + position - 1) % 4]
    end
  end

  def deal
    Bridge.id_to_deal(deal_id.to_i)
  end

  def first_lead_user
    bids.final.first.user.next
  end

  def users
    [user_n, user_e, user_s, user_w]
  end

  [:n, :e, :s, :w].each do |hand|
    define_method("#{hand}_hand") do
      deal[hand]
    end
  end

  state_machine :initial => :auction do
    event :bid_made do
      transition :auction => :playing, :if => :passed?
    end
    event :card_played do
      transition :playing => :completed, :if => :cards_played?
    end

    # after_transition :auction => :playing, :do => :set_contract
    # after_transition :playing => :completed, :do => :set_result
  end
end

module CardsBoardExtension
  extend ActiveSupport::Memoizable

  def trick(n)
    where(:position => ((n - 1) * 4 + 1)..(n * 4)).all
  end

  def tricks
    in_groups_of(4, false)
  end

  def completed_tricks_count
    count.div(4)
  end

  def completed_tricks
    tricks[0...completed_tricks_count]
  end

  def current_position
    count + 1
  end

  def current_lead_position
    current_position - (current_position - 1) % 4
  end

  def previous_lead_position
    current_lead_position - 4
  end

  def current_lead?
    current_position == current_lead_position
  end

  def previous_lead
    where(:position => previous_lead_position).first
  end

  def current_lead
    where(:position => current_lead_position).first
  end

  def current_trick_suit
    current_lead && current_lead.suit
  end

  def current_trick
    where(:position => current_lead_position..(current_lead_position + 3))
  end

  def previous_trick
    where(:position => previous_lead_position..(previous_lead_position + 3))
  end

  def previous_trick_suit
    previous_lead && previous_lead.suit
  end

  def previous_trick_winner
    return if previous_trick.empty?
    card = Bridge::Trick.new(previous_trick.map(&:card)).winner(@association.owner.contract_trump)
    @association.owner.users.owner(card)
  end

  def current_user
    if current_lead?
      previous_trick_winner || @association.owner.users.lho
    else
      @association.owner.users.owner(last.card).next
    end
  end
  memoize :current_user

  def playing_user
    (current_user.dummy?) ? current_user.partner : current_user
  end
  memoize :playing_user
end

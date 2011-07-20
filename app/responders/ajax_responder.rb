class AjaxResponder < ActionController::Responder
  extend ActiveSupport::Memoizable

  delegate :current_user, :render_to_string, :channel_name, :response, :to => :controller

  # def table
  #   resources.first.reload
  # end
  # memoize :table

  # def table_user(direction)
  #   direction ? table.players[direction].try(:user) : nil
  # end
  # memoize :table_user

  # def serializer
  #   @serializer ||= Serializer.new(table)
  # end
  # memoize :serializer

  # def current_player
  #   table.players.for(current_user)
  # end
  # memoize :current_player

  # def current_player_direction
  #   current_player.try(:direction)
  # end
  # memoize :current_player_direction

  # def serialized_table(direction)
  #   user = direction ? table.players[direction].try(:user) : nil
  #   serializer.config(table_user(direction))
  # end
  # memoize :serialized_table

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def to_format
    set_cache_headers

    return display(resource.errors, :status => :unprocessable_entity) if has_errors?

    # if not get?
    #   Beaconpush.channel_message("table-#{table.id}", serialized_table(nil))

    #   (%w[N E S W] - [current_player_direction]).compact.each do |direction|
    #     Beaconpush.user_message(table_user(direction).id.to_s, serialized_table(direction)) if table_user(direction)
    #   end
    # end

    # render :text => serialized_table(current_player_direction).to_json
  end
end

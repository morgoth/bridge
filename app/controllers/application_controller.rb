class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :channel_name

  def channel_name(table, user)
    "table-#{table.id}".tap { |name| name.replace("private-#{name}-user-#{user.id}") if user && table.players.for(user) }
  end
end

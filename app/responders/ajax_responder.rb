class AjaxResponder < ActionController::Responder
  def api_behavior(error)
    if get?
      render :action => default_action
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    else
      table = resources.first.reload

      Pusher["table-#{table.id}"].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => { :table => table, :user => nil }))

      [table.players.n, table.players.e, table.players.s, table.players.w].compact.each do |player|
        Pusher["private-table-#{table.id}-#{player.direction}"].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => { :table => table, :user => player.user }))
      end

      # push stuff
      head :ok
    end
  end
end

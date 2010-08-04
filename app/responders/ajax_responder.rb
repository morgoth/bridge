class AjaxResponder < ActionController::Responder
  def api_behavior(error)
    if get?
      render :action => default_action
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    else
      table = resources.first.reload
      serializer = Serializer.new(table)
      current_user = controller.current_user
      current_player = table.players.for(current_user)

      Pusher[controller.channel_name(table, nil)].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => nil}))

      ([table.players.n, table.players.e, table.players.s, table.players.w] - [current_player]).compact.each do |player|
        Pusher[controller.channel_name(table, player.user)].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => player.user}))
      end

      render :template => "ajax/tables/show", :locals => {:serializer => serializer, :user => current_user}
    end
  end
end

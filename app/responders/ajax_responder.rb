class AjaxResponder < ActionController::Responder
  def api_behavior(error)
    if get?
      render :action => default_action
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    else
      table = resources.first.reload
      serializer = Serializer.new(table)

      Pusher[controller.channel_name(table, nil)].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => { :serializer => serializer, :user => nil }))

      [table.players.n, table.players.e, table.players.s, table.players.w].each do |player|
        next if player.nil? or player == table.players.for(controller.current_user)

        Pusher[controller.channel_name(table, player.user)].trigger("update-table-data", controller.render_to_string(:template => "ajax/tables/show", :locals => { :serializer => serializer, :user => player.user }))
      end

      render :template => "ajax/tables/show", :locals => { :serializer => serializer, :user => controller.current_user }
    end
  end
end

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
      serialized_table = {}

      serialized_table[nil] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => nil})
      serialized_table["N"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.n.user}) if table.players.n
      serialized_table["E"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.e.user}) if table.players.e
      serialized_table["S"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.s.user}) if table.players.s
      serialized_table["W"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.w.user}) if table.players.w

      Pusher[controller.channel_name(table, nil)].trigger("update-table-data", serialized_table[nil])

      (%w[N E S W] - [current_player.try(:direction)]).compact.each do |direction|
        Pusher[controller.channel_name(table, table.players[direction].try(:user))].trigger("update-table-data", serialized_table[direction]) if serialized_table[direction]
      end

      render :text => serialized_table[current_player.try(:direction)]
    end
  end
end

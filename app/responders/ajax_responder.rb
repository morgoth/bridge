require "benchmark"

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

      puts "RENDERING TIME"
      Benchmark.bm do |x|
        x.report do
          serialized_table["PUBLIC"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => nil})
          serialized_table["N"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.n.user})
          serialized_table["E"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.e.user})
          serialized_table["S"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.s.user})
          serialized_table["W"] = controller.render_to_string(:template => "ajax/tables/show", :locals => {:serializer => serializer, :user => table.players.w.user})
        end
      end

      puts "PUSHER TIME"
      Benchmark.bm do |x|
        x.report do
          Pusher[controller.channel_name(table, nil)].trigger("update-table-data", serialized_table["PUBLIC"])

          (%w[N E S W] - [current_player.direction]).compact.each do |direction|
            Pusher[controller.channel_name(table, table.players[direction].user)].trigger("update-table-data", serialized_table[direction])
          end
        end
      end

      render :text => serialized_table[current_player.direction]
    end
  end
end

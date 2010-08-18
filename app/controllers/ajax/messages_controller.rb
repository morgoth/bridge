class Ajax::MessagesController < Ajax::BaseController
  skip_before_filter :fetch_board

  def create
    @message = @table.channel.messages.build(params[:message])
    @message.user = current_user
    @message.save!
    head :created
    Pusher["table-#{@table.id}-chat"].trigger("add-message", {:name => @message.user_name, :body => @message.body})
  end
end

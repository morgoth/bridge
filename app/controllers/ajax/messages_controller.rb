class Ajax::MessagesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board
  before_filter :fetch_channel

  def index
    position = request.headers["Last-Position"]
    logger.warn "requested position: #{position}"
    @messages = position ? @channel.messages.after_position(position) : @channel.messages.last(5)
    response["Current-Position"] = @messages.last.position.to_s if @messages.present?
  end

  def create
    @message = @channel.messages.build(params[:message])
    @message.user = current_user
    @message.save
    respond_with(@channel, @message)
  end

  private

  def fetch_channel
    @channel = Channel.find(params[:channel_id])
  end
end

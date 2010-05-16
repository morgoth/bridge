class Ajax::MessagesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board
  before_filter :fetch_channel

  def index
    fresh_when :etag => [current_user, @channel]
    @messages = @channel.messages.after_position(params[:position])
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

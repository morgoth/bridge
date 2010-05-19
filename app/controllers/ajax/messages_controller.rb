class Ajax::MessagesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board
  before_filter :fetch_channel

  def index
    # HACK: AVOID ETAG MD5 HASHING - we need to know position
    def response.etag=(etag); @etag = self["ETag"] = etag end
    # KCAH
    fresh_when :etag => (@channel.messages.last.try(:position).to_s || "0")
    @position = request.headers["If-None-Match"] || "0"
    @messages = @channel.messages.after_position(@position)
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

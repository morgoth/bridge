require "digest/sha2"

class PusherController < ApplicationController
  self.allow_forgery_protection = false

  def auth
    socket_id = params[:socket_id]
    channel_name = params[:channel_name]

    digest = OpenSSL::Digest::Digest.new("sha256")
    signature = OpenSSL::HMAC.hexdigest(digest, Pusher.secret, "#{socket_id}-#{channel_name}")

    render :json => { :auth => "#{Pusher.key}:#{signature}" }
  end
end

class PusherController < ApplicationController
  self.allow_forgery_protection = false

  def auth
    match = params[:channel_name].match(/\Aprivate-table-(\d+)-user-(\d+)\Z/)
    if current_user.present? && match && match[2] && match[2].to_i == current_user.id
      render :json => { :auth => Pusher[params[:channel_name]].socket_auth(params[:socket_id]) }
    else
      render :text => "401 Unauthorized", :status => :unauthorized
    end
  end
end

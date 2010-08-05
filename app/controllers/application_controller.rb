class ApplicationController < ActionController::Base
  include ChannelHelper
  protect_from_forgery

  helper_method :channel_name
end

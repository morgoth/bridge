class HomeController < ApplicationController
  def index
  end

  def private
  end

  def set
    session["user_provider_oauth_token"] = "something"
    head :ok
  end
end

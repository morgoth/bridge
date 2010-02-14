class Guest::BaseController < ApplicationController
  before_filter :require_no_user

  protected

  def require_no_user
    if current_user
      store_location
      redirect_to user_user_path, :notice => "You must be logged out to access this page"
      return false
    end
  end
end

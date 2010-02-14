class User::BaseController < ApplicationController
  before_filter :require_user

  protected

  def require_user
    unless current_user
      store_location
      redirect_to new_guest_user_session_path, :notice => "You must be logged in to access this page"
      return false
    end
  end
end

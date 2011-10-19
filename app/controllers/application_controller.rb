class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= current_session.try(:user)
  end

  def current_session
    Web::Session.find(session)
  end

  def login_required
    unless current_user
      redirect_to new_session_path, :alert => "Login required"
    end
  end
end

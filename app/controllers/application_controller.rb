class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= (website_session = Website::Session.find(session)) && website_session.account.user
  end

  def login_required
    unless current_user
      redirect_to new_session_path, :alert => "Login required"
    end
  end
end

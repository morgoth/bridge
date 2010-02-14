class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user

  protected

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find(session)
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def store_location
    session[:return_to] = request.request_uri if request.get?
  end

  def redirect_back_or_default(default)
    redirect_to(session.delete(:return_to) || default)
  end
end

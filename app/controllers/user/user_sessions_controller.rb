class User::UserSessionsController < User::BaseController
  def destroy
    @user_session = UserSession.find(session)
    @user_session.destroy
    redirect_to home_path, :notice => "Successfully logged out"
  end
end

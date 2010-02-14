class Guest::UserSessionsController < Guest::BaseController
  def new
    @user_session = UserSession.new(session)
  end

  def create
    @user_session = UserSession.new(session, params[:user_session])
    if @user_session.save
      redirect_to home_path, :notice => "Successfully logged in"
    else
      render :new
    end
  end
end

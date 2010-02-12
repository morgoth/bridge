class UserSessionsController < ApplicationController
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

  def destroy
    @user_session = UserSession.find(session)
    @user_session.destroy
    redirect_to home_path, :notice => "Successfully logged out"
  end
end

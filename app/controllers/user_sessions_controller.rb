class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.valid?
      session[:user_id] = @user_session.user_id
      redirect_to home_path, :notice => "Successfully logged in"
    else
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to home_path, :notice => "Successfully logged out"
  end
end

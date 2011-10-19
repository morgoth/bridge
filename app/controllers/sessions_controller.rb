class SessionsController < ApplicationController
  def new
    @session = Web::Session.new(session)
  end

  def create
    @session = Web::Session.new(session, params[:web_session])
    if @session.save
      redirect_to root_path, :notice => "Logged in"
    else
      render :new
    end
  end

  def destroy
    @session = Web::Session.find(session)
    @session.destroy
    redirect_to root_path, :notice => "Logged out"
  end
end

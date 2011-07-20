class SessionsController < ApplicationController
  def new
    @session = Website::Session.new(session)
  end

  def create
    @session = Website::Session.new(session, params[:website_session])
    if @session.save
      redirect_to root_path, :notice => "Logged in"
    else
      render :new
    end
  end

  def destroy
    @session = Website::Session.find(session)
    @session.destroy
    redirect_to root_path, :notice => "Logged out"
  end
end

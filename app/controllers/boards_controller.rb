class BoardsController < ApplicationController
  before_filter :authenticate_user!, :fetch_user

  def index
    @boards = @user.boards
  end

  private

  def fetch_user
    @user = User.find(params[:user_id])
  end
end

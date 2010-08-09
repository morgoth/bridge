class BoardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @boards = user.boards
  end

  private

  def user
    @user = User.find(params[:user_id])
  end
end

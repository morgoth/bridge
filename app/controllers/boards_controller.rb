class BoardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @boards = user.boards
  end

  def show
    @board = user.boards.find(params[:id])
  end

  private

  def user
    @user = User.find(params[:user_id])
  end
end

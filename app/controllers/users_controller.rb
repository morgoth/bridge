class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to home_path, :notice => "Successfully signed up"
    else
      render :new
    end
  end

  def show
    @user = @current_user
  end
end

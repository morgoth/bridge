class User::UsersController < User::BaseController
  def show
    @user = @current_user
  end
end

class Guest::UsersController < Guest::BaseController
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
end

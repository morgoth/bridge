class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable, activatable, :confirmable, :recoverable
  devise :registerable, :database_authenticatable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  # TODO: add display_name to user's model
  def name
    email
  end
end

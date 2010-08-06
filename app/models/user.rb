class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable, activatable, :confirmable, :recoverable
  devise :registerable, :database_authenticatable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :display_name

  validates :display_name, :presence => true, :uniqueness => true

  def name
    display_name
  end

  # Devise method for finding user
  def self.find_for_authentication(conditions)
    where(["email = :auth OR display_name = :auth", {:auth => conditions[:email]}]).first
  end
end

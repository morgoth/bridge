class User < ActiveRecord::Base
  has_one :web_account, :class_name => "Web::Account"

  delegate :name, :email, :to => :account, :allow_nil => true

  def boards
    Board.where(["user_n_id = :user_id OR user_e_id = :user_id OR user_s_id = :user_id OR user_w_id = :user_id", {:user_id => self.id}])
  end

  def account
    web_account || build_web_account
  end
end

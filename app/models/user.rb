class User < ActiveRecord::Base
  has_one :website_account, :class_name => "Website::Account"

  delegate :name, :email, :to => :account, :allow_nil => true

  def boards
    Board.where(["user_n_id = :user_id OR user_e_id = :user_id OR user_s_id = :user_id OR user_w_id = :user_id", {:user_id => self.id}])
  end

  def account
    website_account || build_website_account
  end
end

class User < ActiveRecord::Base
  def boards
    Board.where(["user_n_id = :user_id OR user_e_id = :user_id OR user_s_id = :user_id OR user_w_id = :user_id", {:user_id => self.id}])
  end
end

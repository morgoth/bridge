module UserBoardExtension
  include UserExtension

  def direction
    proxy_reflection.name.to_s[-1].upcase
  end

  private

  def board
    proxy_owner
  end
end

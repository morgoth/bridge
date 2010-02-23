require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  test "hands methods should return cards" do
    board = Factory(:board)
    assert_equal board.deck[:n], board.n_hand
    assert_equal board.deck[:e], board.e_hand
    assert_equal board.deck[:s], board.s_hand
    assert_equal board.deck[:w], board.w_hand
  end
end

require 'test_helper'

class AjaxHelperTest < ActionView::TestCase
  setup do
    @table = Factory(:table_with_players)
  end

  test "serialize players" do
    expected = { "N"=> { "name" => @table.players["N"].name },
                 "E"=> { "name" => @table.players["E"].name },
                 "S"=> { "name" => @table.players["S"].name },
                 "W"=> { "name" => @table.players["W"].name }
                }
    assert_equal expected, serialize_players(@table.players)
  end

  test "serialize player" do
    expected = { "name" => @table.players["N"].name }
    assert_equal expected, serialize_player(@table.players["N"])
  end

  test "serialize board" do
    pending("stub current_user") do
      expected = {}
      assert_equal expected, serialize_board(@table.boards.current)
    end
  end
end
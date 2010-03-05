require "test_helper"

class TableWithPlayersTest < ActiveSupport::TestCase
  setup do
    @table = Factory(:table_with_players)
  end

  test "starts if every player is ready" do
    assert @table.reload.preparing?
    @table.players[0].start!
    assert @table.reload.preparing?
    @table.players[1].start!
    assert @table.reload.preparing?
    @table.players[2].start!
    assert @table.reload.preparing?
    @table.players[3].start!
    assert @table.reload.playing?
  end
end

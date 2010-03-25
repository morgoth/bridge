require "test_helper"

class AuctionTest < ActionController::IntegrationTest
  test "simple auction" do
    table = Factory(:table_with_players)

    user_n = table.players.n.user.tap { |u| u.password = "secret" }
    user_e = table.players.e.user.tap { |u| u.password = "secret" }
    user_s = table.players.s.user.tap { |u| u.password = "secret" }
    user_w = table.players.w.user.tap { |u| u.password = "secret" }

    login(user_n)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-biddingbox") { click_button("PASS") }
    wait_until_ready
    assert has_css?(".yui-auction-bid:contains('PASS')")

    login(user_e)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-biddingbox") do
      click_button("1")
      click_button("C")
    end
    wait_until_ready
    assert has_css?(".yui-auction-bid:contains('1C')")

    login(user_s)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-biddingbox") { click_button("X") }
    wait_until_ready
    assert has_css?(".yui-auction-bid:contains('X')")

    login(user_w)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-biddingbox") { click_button("XX") }
    wait_until_ready
    assert has_css?(".yui-auction-bid:contains('XX')")
  end
end

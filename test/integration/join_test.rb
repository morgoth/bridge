require "test_helper"

class JoinTest < ActionController::IntegrationTest
  test "users are able to join the table" do
    table = Factory(:table)
    user_n, user_e, user_s, user_w = [Factory(:user), Factory(:user), Factory(:user), Factory(:user)]

    login(user_n)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-hand-n") { click_button("Join") }
    wait_until_ready
    assert has_css?(".yui-hand-name:contains('#{user_n.name}')")

    login(user_e)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-hand-e") { click_button("Join") }
    wait_until_ready
    assert has_css?(".yui-hand-name:contains('#{user_e.name}')")

    login(user_s)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-hand-s") { click_button("Join") }
    wait_until_ready
    assert has_css?(".yui-hand-name:contains('#{user_s.name}')")

    login(user_w)
    click("Table ##{table.id}")
    wait_until_ready
    within(".bridge-hand-w") { click_button("Join") }
    wait_until_ready
    assert has_css?(".yui-hand-name:contains('#{user_w.name}')")
  end
end

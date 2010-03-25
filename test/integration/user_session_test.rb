require "test_helper"

class UserSessionTest < ActionController::IntegrationTest
  test "user is able to login" do
    user = Factory(:user)

    visit(root_path)
    click("Log in")
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Login")

    assert page.has_content?("Successfully logged in")
  end
end

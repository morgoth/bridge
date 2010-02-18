require 'test_helper'

class UserSessionTest < ActionController::IntegrationTest
  test "should be able to login" do
    user = Factory(:user)

    visit(new_guest_user_session_path)
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Login")

    assert page.has_content?("Successfully logged in")

    visit(user_user_path)
    assert page.has_content?(user.email)
  end
end

require "test_helper"

class UserSessionTest < ActionController::IntegrationTest
  test "user is able to login" do
    user = Factory(:user)

    visit(root_path)
    click("Sign in")
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Sign in")

    assert page.has_content?("Signed in successfully.")
  end
end

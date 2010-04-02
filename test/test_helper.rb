ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "factory_girl_helper"
require "capybara_helper"

Capybara.default_selector = :css
Capybara.default_driver = :selenium

DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
end

class ActionController::IntegrationTest
  include Capybara

  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean
  end

  def login(user = Factory(:user))
    visit(root_path)
    click_button("Log out") rescue nil
    click("Log in")
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Login")
  end

  def wait_until_ready
    until(execute_script("return window.READY;"))
      sleep 0.2
    end
  end

  def execute_script(script)
    Capybara.current_session.driver.browser.execute_script(script)
  end
end

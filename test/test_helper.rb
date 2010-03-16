ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

require "factory_girl_helper"
require "capybara_helper"

Capybara.default_selector = :css
Capybara.default_driver = :selenium

class ActiveSupport::TestCase
end

class ActionController::IntegrationTest
  include Capybara
end

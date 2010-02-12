ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

require "factory_girl_helper"
require "capybara_helper"

class ActiveSupport::TestCase

end

class ActionController::IntegrationTest
  include Capybara
end

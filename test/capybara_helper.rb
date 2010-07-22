require "capybara"
require "capybara/dsl"

Capybara.app = Rack::Builder.new { run Libre::Application }
Capybara.asset_root = Rails.root.join("public")

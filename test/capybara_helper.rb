require 'capybara'
require 'capybara/dsl'

Capybara.app = Rack::Builder.new do
  run Libre::Application
end

Capybara.asset_root = Rails.root.join('public')


require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Libre
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :test_unit, :fixture => false
    end

    config.action_controller.cookie_verifier_secret = "707d2a134650acb093677eafef6275f72239c1e4b86fb5c19774025c64e435c11215e4c9d84c36df6e0d63c0247fd238b9562f9900fa54ad6e3acb6e806e1a88"

    config.action_controller.session = {
      :key    => "_libre_session",
      :secret => "23e008610b365fe6073beec0b37b78217370671b4df84e1a06050c4755b8956d34dd463ab974773341d69a93c50af2b5d2987237ae7371e8523576c0d2e81157"
    }

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
  end
end

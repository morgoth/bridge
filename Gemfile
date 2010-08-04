source :rubygems

gem "rails", :git => "http://github.com/rails/rails.git"

gem "acts_as_list"
gem "bridge"
gem "compass"
gem "devise", :git => "http://github.com/plataformatec/devise.git"
gem "haml"
gem "proxies"
gem "pusher"
gem "sqlite3-ruby", :group => [:development, :test]
gem "state_machine"

group :development do
  gem "rails3-generators"
end

group :test do
  gem "capybara", :require => nil
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "mocha"
  gem "test-unit", :require => "test/unit"
end

group :production do
  gem "pg"
end

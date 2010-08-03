source :rubygems

gem "rails", :git => "http://github.com/rails/rails.git"

gem "acts_as_list"
gem "bridge"
gem "compass"
gem "devise", :git => "http://github.com/plataformatec/devise.git"
gem "haml"
gem "proxies"
gem "sqlite3-ruby", :group => [:development, :test]
gem "state_machine", :git => "git://github.com/pluginaweek/state_machine.git"

group :development do
  gem "rails3-generators"
end

group :test do
  gem "capybara", :require => nil
  gem "factory_girl_rails"
  gem "test-unit", :require => "test/unit"
  gem "database_cleaner"
  gem "mocha"
end

group :production do
  gem "pg"
end

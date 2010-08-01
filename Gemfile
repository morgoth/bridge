source :rubygems

gem "rails", "3.0.0.rc"

gem "acts_as_list"
gem "bridge"
gem "haml"
gem "state_machine", :git => "git://github.com/pluginaweek/state_machine.git"
gem "compass"
gem "proxies"
gem "devise", "1.1.0"
gem "sqlite3-ruby", :group => [:development, :test]

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

source "http://rubygems.org"

gem "rails", :git => "git://github.com/rails/rails.git"

gem "acts_as_list"
gem "bridge", ">=0.0.23"
gem "haml", ">=2.2.22"
gem "state_machine", ">=0.8.1"
gem "compass"
gem "sqlite3", :groups => [:development, :test]

group :development do
  gem "rails3-generators"
end

group :test do
  gem "capybara", :require => nil
  gem "factory_girl", :require => nil
  gem "test-unit", ">=2", :require => "test/unit"
  gem "database_cleaner"
  gem "mocha"
end

group :production do
  gem "pg"
end

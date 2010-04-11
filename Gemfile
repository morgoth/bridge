source "http://rubygems.org"

gem "rails", :git => "git://github.com/rails/rails.git", :ref => "7353fc15957aa3b32eae8cf495701a7163cf8dbc"

gem "bundler", ">=0.9.18"
gem "acts_as_list"
gem "bridge", ">=0.0.23"
gem "haml", ">=2.2.22"
gem "state_machine", ">=0.8.1"
gem "compass"
gem "proxies"
gem "devise", :git => "git://github.com/plataformatec/devise.git"
gem "sqlite3", :group => [:development, :test]

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

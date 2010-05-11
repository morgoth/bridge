source "http://rubygems.org"

gem "rails", :git => "git://github.com/rails/rails.git"

gem "bundler", ">=0.9.19"
gem "acts_as_list"
gem "bridge", ">=0.0.23"
gem "haml", ">=3.0.0"
gem "state_machine", ">=0.9.1"
gem "compass", ">= 0.10.0"
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

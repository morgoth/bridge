source "http://rubygems.org"

gem "rails", "3.1.0.rc4"

gem "acts_as_list"
gem "bridge"
gem "proxies"
gem "beaconpush"
gem "sqlite3", :group => [:development, :test]
gem "state_machine"

group :test do
  gem "factory_girl_rails"
  gem "mocha"
  gem "turn", :require => false
end

group :production do
  gem "pg"
  gem "dalli"
end

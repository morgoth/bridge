source "http://rubygems.org"

gem "rails", "3.1.0.rc4"

gem "acts_as_list"
gem "bridge"
gem "proxies"
gem "beaconpush"
gem "state_machine"
gem "sprockets", "2.0.0.beta10"

group :development, :test do
  gem "sqlite3"
  gem "ruby-debug19", :require => "ruby-debug", :platform => :ruby_19
end

group :test do
  gem "factory_girl_rails", "~> 1.1.rc1"
  gem "mocha"
  gem "turn", :require => false
end

group :production do
  gem "pg"
  gem "dalli"
end
